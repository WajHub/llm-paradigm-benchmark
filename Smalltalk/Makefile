DIR ?= .
GST = gst

test:
	$(GST) -g `ls $(DIR)/*.st 2>/dev/null | grep -v Tests.st | sort`

clean:
	@true
