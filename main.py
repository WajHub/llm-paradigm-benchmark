import os
import shutil
import sys

from dotenv import load_dotenv
from openai import OpenAI
from openai.types.chat import ChatCompletionMessageParam

# Load environment variables from the .env file
load_dotenv()

# ==========================================
# --- LLM BACKEND CONFIGURATION ---
# ==========================================

ACTIVE_PROVIDER = "gemini"

API_KEYS = {
    "openai": os.environ.get("OPENAI_API_KEY"),
    "openrouter": os.environ.get("OPENROUTER_API_KEY"),
    "gemini": os.environ.get("GEMINI_API_KEY"),
}

PROVIDERS = {
    "ollama": {
        "base_url": "http://localhost:11434/v1",
        "api_key": "ollama",
        "model": "gemma2:27b",
    },
    "openai": {
        "base_url": "https://api.openai.com/v1",
        "api_key": API_KEYS["openai"],
        "model": "gpt-4o",
    },
    "openrouter": {
        "base_url": "https://openrouter.ai/api/v1",
        "api_key": API_KEYS["openrouter"],
        "model": "google/gemma-4-31b-it:free",
    },
    "gemini": {
        "base_url": "https://generativelanguage.googleapis.com/v1beta/openai/",
        "api_key": API_KEYS["gemini"],
        "model": "gemini-3.1-flash-lite",
    },
}

TEMPERATURE = 0.8
MAX_TOKENS = 2048

# ==========================================
# --- BENCHMARK CONFIGURATION ---
# ==========================================
REPO_PATH = "."
LANGUAGE = "Java"
TEST_NAME = "test-1"

INTERFACE_FILE = "SpatialLogic.java"
IMPLEMENTATION_FILE = "SpatialLogicImpl.java"


def main():
    if ACTIVE_PROVIDER not in PROVIDERS:
        print(f"❌ Invalid ACTIVE_PROVIDER '{ACTIVE_PROVIDER}'.")
        sys.exit(1)

    config = PROVIDERS[ACTIVE_PROVIDER]

    if ACTIVE_PROVIDER != "ollama" and not config["api_key"]:
        print(
            f"❌ Missing API key for {ACTIVE_PROVIDER}. Please add it to your .env file."
        )
        sys.exit(1)

    print(f"🔌 Connecting to {ACTIVE_PROVIDER.upper()} [{config['base_url']}]...")
    client = OpenAI(api_key=config["api_key"], base_url=config["base_url"])
    active_model = config["model"]

    test_dir_path = os.path.join(REPO_PATH, LANGUAGE, TEST_NAME)
    requirements_path = os.path.join(test_dir_path, f"{TEST_NAME}.md")
    interface_path = os.path.join(test_dir_path, INTERFACE_FILE)
    output_path = os.path.join(test_dir_path, IMPLEMENTATION_FILE)

    try:
        with open(requirements_path, "r", encoding="utf-8") as f:
            task_requirements = f.read()
        with open(interface_path, "r", encoding="utf-8") as f:
            interface_content = f.read()
    except FileNotFoundError as e:
        print(f"❌ Error reading benchmark files: {e}")
        return

    print(f"📝 Constructing initial prompt for {LANGUAGE} / {TEST_NAME}...")

    initial_prompt = f"""You are a {LANGUAGE} programming expert. Your task is to implement the required methods in accordance with the provided class or interface.

[TASK-SPECIFIC REQUIREMENTS]
{task_requirements}

General Requirements:
- Use idiomatic {LANGUAGE}.
- Use object-oriented design and model the domain with classes.
- Prefer standard library collections and utilities where appropriate.
- Return ONLY raw {LANGUAGE} code (no Markdown tags, no ``` blocks, no side text). Your code will be directly saved to a source file and compiled. Do not provide a main() method or test code.

[INTERFACE CONTENT]
{interface_content}
"""

    # We use a list to keep track of the conversation history for follow-ups
    # messages = [{"role": "user", "content": initial_prompt}]
    messages: list[ChatCompletionMessageParam] = [
        {"role": "user", "content": initial_prompt}
    ]
    attempt = 1

    while True:
        print(
            f"\n⏳ [Attempt {attempt}] Requesting code generation from {active_model}..."
        )
        try:
            response = client.chat.completions.create(
                model=active_model,
                messages=messages,
                temperature=TEMPERATURE,
                max_tokens=MAX_TOKENS,
            )
        except Exception as e:
            print(f"\n🚨 CRITICAL ERROR: {e}")
            return

        completion = response.choices[0].message.content

        # --- NEW SAFETY CHECK ---
        if not completion:
            # Safely try to grab the finish_reason so we know why it failed
            finish_reason = getattr(response.choices[0], "finish_reason", "Unknown")
            print(
                f"\n❌ Error: The model returned an empty response. (Finish reason: {finish_reason})"
            )
            print(
                "This usually happens if a safety filter blocked the output, or the model glitched."
            )
            break
        # ------------------------

        # Sanitize Output
        lines = completion.strip().split("\n")
        if lines and lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].startswith("```"):
            lines = lines[:-1]
        clean_code = "\n".join(lines)

        # Back up reference solution only on the first attempt
        backup_path = output_path + ".backup"
        if (
            attempt == 1
            and not os.path.exists(backup_path)
            and os.path.exists(output_path)
        ):
            shutil.copy2(output_path, backup_path)
            print(f"📦 Backed up original reference solution to: {backup_path}")

        # Save generated code
        with open(output_path, "w", encoding="utf-8") as out_f:
            out_f.write(clean_code)

        print(f"✅ Saved generated code to: {output_path}")
        print("\n👉 Leave this script running. Open a new terminal and run:")
        print(f"   cd {os.path.join(REPO_PATH, LANGUAGE)}")
        print(f"   docker compose run --rm evaluator {TEST_NAME}")

        # Interactive Check
        status = input("\nDid the tests pass? (y/n): ").strip().lower()

        if status == "y":
            print("🎉 Awesome! The LLM successfully passed the benchmark.")
            break
        elif status == "n":
            print("\n❌ Tests failed. Let's send the follow-up prompt.")
            test_case = input("Enter the failing test case (Code or name): ").strip()

            print("Paste the ERROR LOGS / COMPILER OUTPUT below.")
            print("Type 'END' on a new line and press Enter when you are done pasting:")
            log_lines = []
            while True:
                line = input()
                if line.strip() == "END":
                    break
                log_lines.append(line)
            error_logs = "\n".join(log_lines)

            follow_up_prompt = f"""Your previous {LANGUAGE} implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

[ERROR LOGS / COMPILER OUTPUT]
{error_logs}

[FAILING TEST CASE ({test_case})]

Requirements for the fix:
1. Identify and resolve the core logical or resource-management issue causing the failure.
2. Ensure resources are handled safely.
3. Return ONLY the complete, raw, fixed {LANGUAGE} code for the target source file.
4. Do NOT include Markdown formatting, do NOT include ``` blocks, and do NOT write any explanations. Just the code."""

            # Save the assistant's previous code into the history so it has context
            messages.append({"role": "assistant", "content": completion})
            # Add the user's follow-up prompt
            messages.append({"role": "user", "content": follow_up_prompt})

            attempt += 1
        else:
            print("Invalid input. Assuming you want to exit.")
            break


if __name__ == "__main__":
    main()