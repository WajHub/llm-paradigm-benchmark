module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad (forM)
import System.Exit (exitFailure, exitSuccess)
import SpatialLogic

type TestCase = (String, Bool)

approxEq :: Double -> Double -> Bool
approxEq a b = abs (a - b) < 0.001

containsPoint :: Polygon -> Double -> Double -> Bool
containsPoint poly x y = any matchesPoint (polygonVertices poly)
  where
    matchesPoint point = approxEq (pointX point) x && approxEq (pointY point) y

polygonArea :: Polygon -> Double
polygonArea poly =
  case polygonVertices poly of
    [] -> 0
    points ->
      let pairs = zip points (tail points ++ [head points])
      in 0.5 * sum [pointX a * pointY b - pointX b * pointY a | (a, b) <- pairs]

polygonIsCCW :: Polygon -> Bool
polygonIsCCW poly = polygonArea poly > 1e-9

polygonHasNoCollinear :: Polygon -> Bool
polygonHasNoCollinear poly
  | length points < 3 = True
  | otherwise = all nonCollinear triplets
  where
    points = polygonVertices poly
    triplets = zip3 points (drop 1 points ++ take 1 points) (drop 2 points ++ take 2 points)
    nonCollinear (a, b, c) = abs ((pointX b - pointX a) * (pointY c - pointY a) - (pointY b - pointY a) * (pointX c - pointX a)) > 1e-6

polygonMatchesExpected :: Polygon -> [Point] -> Bool
polygonMatchesExpected poly expected =
  length actual == length expected && all matches expected
  where
    actual = polygonVertices poly
    matches point = any (samePoint point) actual
    samePoint a b = approxEq (pointX a) (pointX b) && approxEq (pointY a) (pointY b)

makePolygon :: [Point] -> String -> Polygon
makePolygon points name = Polygon points (length points) True name

check :: String -> Bool -> IO Bool
check name passed = do
  result <- try (evaluate passed) :: IO (Either SomeException Bool)
  case result of
    Right True -> do
      putStrLn $ "[PASS] " ++ name
      pure True
    Right False -> do
      putStrLn $ "[FAIL] " ++ name
      pure False
    Left _ -> do
      putStrLn $ "[FAIL] " ++ name
      pure False

testAlgoA01BasicSquares :: Bool
testAlgoA01BasicSquares =
  let poly1 = makePolygon [Point 0 0, Point 2 0, Point 2 2, Point 0 2] "Z1"
      poly2 = makePolygon [Point 0 0, Point 2 0, Point 2 2, Point 0 2] "Z2"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result ->
         polygonMatchesExpected result [Point 0 0, Point 4 0, Point 4 4, Point 0 4]
         && polygonIsCCW result
         && polygonHasNoCollinear result
         && polygonIsConvex result

testAlgoA02PointAndPolygon :: Bool
testAlgoA02PointAndPolygon =
  let poly1 = makePolygon [Point 5 5] "Point"
      poly2 = makePolygon [Point 0 0, Point 1 0, Point 0 1] "Triangle"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result ->
         polygonMatchesExpected result [Point 5 5, Point 6 5, Point 5 6]
         && polygonIsCCW result
         && polygonHasNoCollinear result

testAlgoA03CollinearSimplification :: Bool
testAlgoA03CollinearSimplification =
  let poly1 = makePolygon [Point 0 0, Point 2 0, Point 0 2] "Tri1"
      poly2 = makePolygon [Point 0 0, Point 2 0, Point 0 2] "Tri2"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result ->
         polygonMatchesExpected result [Point 0 0, Point 4 0, Point 0 4]
         && polygonIsCCW result
         && polygonHasNoCollinear result

testAlgoA04NegativeCoordinates :: Bool
testAlgoA04NegativeCoordinates =
  let poly1 = makePolygon [Point (-5) (-5), Point (-3) (-5), Point (-3) (-3), Point (-5) (-3)] "NegSq"
      poly2 = makePolygon [Point 1 1, Point 2 1, Point 2 2, Point 1 2] "PosSq"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result ->
         length (polygonVertices result) == 4
         && containsPoint result (-4) (-4)
         && containsPoint result (-1) (-1)
         && polygonIsCCW result
         && polygonHasNoCollinear result

testAlgoA05SinglePoints :: Bool
testAlgoA05SinglePoints =
  let poly1 = makePolygon [Point (-2.5) 3.5] "Pt1"
      poly2 = makePolygon [Point 2.5 (-3.5)] "Pt2"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result ->
         length (polygonVertices result) == 1
         && containsPoint result 0 0

testAlgoA06EmptyFirstPolygon :: Bool
testAlgoA06EmptyFirstPolygon =
  let poly1 = makePolygon [] "Empty"
      poly2 = makePolygon [Point 0 0, Point 1 1] "Line"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result -> null (polygonVertices result)

testAlgoA07EmptySecondPolygon :: Bool
testAlgoA07EmptySecondPolygon =
  let poly1 = makePolygon [Point 0 0, Point 1 1] "Line"
      poly2 = makePolygon [] "Empty"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result -> null (polygonVertices result)

testAlgoA08NullArguments :: Bool
testAlgoA08NullArguments =
  let poly = makePolygon [Point 0 0] "Pt"
      res1 = calculateCleanMinkowskiSum Nothing (Just poly)
      res2 = calculateCleanMinkowskiSum (Just poly) Nothing
      res3 = calculateCleanMinkowskiSum Nothing Nothing
  in res1 == Nothing && res2 == Nothing && res3 == Nothing

testAlgoA09FlatPolygon :: Bool
testAlgoA09FlatPolygon =
  let poly1 = makePolygon [Point 0 0, Point 2 0] "Line1"
      poly2 = makePolygon [Point 0 0, Point 3 0] "Line2"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result ->
         length (polygonVertices result) == 2
         && containsPoint result 0 0
         && containsPoint result 5 0

testAlgoA10StressTest :: Bool
testAlgoA10StressTest =
  let size :: Int
      size = 500
      circlePoints =
        [ Point (cos (2.0 * pi * fromIntegral i / fromIntegral size))
                (sin (2.0 * pi * fromIntegral i / fromIntegral size))
        | i <- [0 .. size - 1]
        ]
      poly1 = makePolygon circlePoints "Circle1"
      poly2 = makePolygon circlePoints "Circle2"
  in case calculateCleanMinkowskiSum (Just poly1) (Just poly2) of
       Nothing -> False
       Just result -> not (null (polygonVertices result))

testAlgoB01TunnelingCollision :: Bool
testAlgoB01TunnelingCollision =
  let robot = makePolygon [Point 0 0, Point 1 0, Point 1 1, Point 0 1] "Robot"
      obstacle = makePolygon [Point 5 0, Point 6 0, Point 6 1, Point 5 1] "Obstacle"
  in checkDynamicCollision (Just obstacle) (Just robot) (Point 10 0)

testAlgoB02ClearMiss :: Bool
testAlgoB02ClearMiss =
  let robot = makePolygon [Point 0 0, Point 1 0, Point 1 1, Point 0 1] "Robot"
      obstacle = makePolygon [Point 0 5, Point 1 5, Point 1 6, Point 0 6] "Obstacle"
  in not (checkDynamicCollision (Just obstacle) (Just robot) (Point 10 0))

testAlgoB03StaticOverlap :: Bool
testAlgoB03StaticOverlap =
  let robot = makePolygon [Point 0 0, Point 2 0, Point 2 2, Point 0 2] "Robot"
      obstacle = makePolygon [Point 1 1, Point 3 1, Point 3 3, Point 1 3] "Obstacle"
  in checkDynamicCollision (Just obstacle) (Just robot) (Point 0 0)

testAlgoB04StaticMiss :: Bool
testAlgoB04StaticMiss =
  let robot = makePolygon [Point 0 0, Point 1 0, Point 1 1, Point 0 1] "Robot"
      obstacle = makePolygon [Point 10 10, Point 11 10, Point 11 11, Point 10 11] "Obstacle"
  in not (checkDynamicCollision (Just obstacle) (Just robot) (Point 0 0))

testAlgoB05MovingAway :: Bool
testAlgoB05MovingAway =
  let robot = makePolygon [Point 0 0, Point 1 0, Point 1 1, Point 0 1] "Robot"
      obstacle = makePolygon [Point (-5) 0, Point (-4) 0, Point (-4) 1, Point (-5) 1] "Obstacle"
  in not (checkDynamicCollision (Just obstacle) (Just robot) (Point 10 0))

testAlgoB06DiagonalTunneling :: Bool
testAlgoB06DiagonalTunneling =
  let robot = makePolygon [Point 0 0, Point 1 0, Point 1 1, Point 0 1] "Robot"
      obstacle = makePolygon [Point 5 5, Point 7 5, Point 7 7, Point 5 7] "Obstacle"
  in checkDynamicCollision (Just obstacle) (Just robot) (Point 10 10)

testAlgoB07EdgeGrazing :: Bool
testAlgoB07EdgeGrazing =
  let robot = makePolygon [Point 0 0, Point 1 0, Point 1 1, Point 0 1] "Robot"
      obstacle = makePolygon [Point 0 1, Point 1 1, Point 1 2, Point 0 2] "Obstacle"
  in checkDynamicCollision (Just obstacle) (Just robot) (Point 10 0)

testAlgoB08NegativeVelocity :: Bool
testAlgoB08NegativeVelocity =
  let robot = makePolygon [Point 10 10, Point 11 10, Point 11 11, Point 10 11] "Robot"
      obstacle = makePolygon [Point 4 4, Point 6 4, Point 6 6, Point 4 6] "Obstacle"
  in checkDynamicCollision (Just obstacle) (Just robot) (Point (-10) (-10))

testAlgoB09EmptyPolygons :: Bool
testAlgoB09EmptyPolygons =
  let emptyPoly = makePolygon [] "Empty"
      obstacle = makePolygon [Point 0 0, Point 1 0, Point 1 1, Point 0 1] "Obstacle"
      col1 = checkDynamicCollision (Just obstacle) (Just emptyPoly) (Point 5 5)
      col2 = checkDynamicCollision (Just emptyPoly) (Just obstacle) (Point 5 5)
  in not col1 && not col2

testAlgoB10NullArguments :: Bool
testAlgoB10NullArguments =
  let obstacle = makePolygon [Point 0 0, Point 1 0, Point 1 1, Point 0 1] "Obstacle"
      col1 = checkDynamicCollision Nothing (Just obstacle) (Point 5 5)
      col2 = checkDynamicCollision (Just obstacle) Nothing (Point 5 5)
      col3 = checkDynamicCollision Nothing Nothing (Point 5 5)
  in not col1 && not col2 && not col3

tests :: [TestCase]
tests =
  [ ("Test A01 (Basic Squares Hull)", testAlgoA01BasicSquares)
  , ("Test A02 (Point and Polygon)", testAlgoA02PointAndPolygon)
  , ("Test A03 (Collinear Simplification)", testAlgoA03CollinearSimplification)
  , ("Test A04 (Negative Coordinates)", testAlgoA04NegativeCoordinates)
  , ("Test A05 (Single Points)", testAlgoA05SinglePoints)
  , ("Test A06 (Empty First Polygon)", testAlgoA06EmptyFirstPolygon)
  , ("Test A07 (Empty Second Polygon)", testAlgoA07EmptySecondPolygon)
  , ("Test A08 (Null Arguments)", testAlgoA08NullArguments)
  , ("Test A09 (Flat Polygons / Lines)", testAlgoA09FlatPolygon)
  , ("Test A10 (Stress Test 500x500)", testAlgoA10StressTest)
  , ("Test B01 (Tunneling Collision)", testAlgoB01TunnelingCollision)
  , ("Test B02 (Clear Miss)", testAlgoB02ClearMiss)
  , ("Test B03 (Static Overlap)", testAlgoB03StaticOverlap)
  , ("Test B04 (Static Miss)", testAlgoB04StaticMiss)
  , ("Test B05 (Moving Away)", testAlgoB05MovingAway)
  , ("Test B06 (Diagonal Tunneling)", testAlgoB06DiagonalTunneling)
  , ("Test B07 (Edge Grazing)", testAlgoB07EdgeGrazing)
  , ("Test B08 (Negative Velocity)", testAlgoB08NegativeVelocity)
  , ("Test B09 (Empty Polygons)", testAlgoB09EmptyPolygons)
  , ("Test B10 (NULL Arguments)", testAlgoB10NullArguments)
  ]

main :: IO ()
main = do
  results <- forM tests (uncurry check)
  let totalTests = length tests
      passedCount = length (filter id results)
      failedCount = totalTests - passedCount
      failedTests = [name | ((name, _), passed) <- zip tests results, not passed]

  putStrLn ""
  putStrLn "=== BENCHMARK RESULTS ==="
  putStrLn $ "Completed " ++ show totalTests ++ " tests."
  putStrLn $ "Passed: " ++ show passedCount
  putStrLn $ "Failed: " ++ show failedCount

  if and results
    then exitSuccess
    else do
      putStrLn "Tests that failed:"
      mapM_ (putStrLn . (" - " ++)) failedTests
      exitFailure
