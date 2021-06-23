~~~~~~ Scala 
/*
This example shows how a block of data can be ingested and then individual tuples
can be parsed out of that data block. It is a very tiny example. But, it demonstrates
one of the ways in which the Parse operator can be put to use.

Following code block was obtained from the Streams InfoCenter. Full credit goes to
the authors of the Streams InfoCenter. 
*/
namespace com.acme.test;

composite ConvertBlockDataWithParse {
	graph
		// Read a block of data from a file.
		stream<blob b> TestData1 = FileSource() {
			param
				file: "test1.txt";
				format: block;
				blockSize: 1u;
		}
		
		// Parse every line in the blob and send it as an individual tuple.
		stream<rstring s, float64 d, rstring q> ParsedData = Parse(TestData1) {
			param
				format: txt;
		}
		
		// Display each tuple on the stdout.
		() as MySink1 = FileSink(ParsedData) {
			param
				file: "/dev/stdout";
				format: txt;
		}
}

~~~~~~
