
package CppCalculator_cpp;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Annotation; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeEvaluator; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::TupleValue; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   print '/* Additional includes go here */', "\n";
   print "\n";
   SPL::CodeGen::implementationPrologue($model);
   print "\n";
   print "\n";
   print '// To support the consistent regions, this operator must do this check.', "\n";
      my $isInConsistentRegion = $model->getContext()->getOptionalContext("ConsistentRegion");
   print "\n";
   print "\n";
   print '// Constructor', "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::MY_OPERATOR()', "\n";
   print '{', "\n";
   print '	// This operator must do this registration needed for consistent regions.', "\n";
   print '    ';
   if ($isInConsistentRegion) {
   print "\n";
   print '      getContext().registerStateHandler(*this);', "\n";
   print '    ';
   }
   print "\n";
   print '    ', "\n";
   print '    tupleCnt = 0;', "\n";
   print '}', "\n";
   print "\n";
   print '// Destructor', "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::~MY_OPERATOR() ', "\n";
   print '{', "\n";
   print '    // Finalization code goes here', "\n";
   print '}', "\n";
   print "\n";
   print '// Notify port readiness', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::allPortsReady() ', "\n";
   print '{', "\n";
   print '    // Notifies that all ports are ready. No tuples should be submitted before', "\n";
   print '    // this. Source operators can use this method to spawn threads.', "\n";
   print "\n";
   print '    /*', "\n";
   print '      createThreads(1); // Create source thread', "\n";
   print '    */', "\n";
   print '}', "\n";
   print ' ', "\n";
   print '// Notify pending shutdown', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::prepareToShutdown() ', "\n";
   print '{', "\n";
   print '    // This is an asynchronous call', "\n";
   print '}', "\n";
   print "\n";
   print '// Processing for source and threaded operators   ', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(uint32_t idx)', "\n";
   print '{', "\n";
   print '    // A typical implementation will loop until shutdown', "\n";
   print '    /*', "\n";
   print '      while(!getPE().getShutdownRequested()) {', "\n";
   print '          // do work ...', "\n";
   print '      }', "\n";
   print '    */', "\n";
   print '}', "\n";
   print "\n";
   print '// Tuple processing for mutating ports ', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple & tuple, uint32_t port)', "\n";
   print '{', "\n";
   print '    // Sample submit code', "\n";
   print '    /* ', "\n";
   print '      submit(otuple, 0); // submit to output port 0', "\n";
   print '    */', "\n";
   print '}', "\n";
   print "\n";
   print '// Tuple processing for non-mutating ports', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple const & tuple, uint32_t port)', "\n";
   print '{', "\n";
   print '	// 1) We will receive the calculation requests and perform the simple calculations.', "\n";
   print '	// ', "\n";
   print '	// 2) Results from those calculations will be kept inside the local ', "\n";
   print '	// state (member) variables of this operator. We will not submit any result.  ', "\n";
   print '	// ', "\n";
   print '	// 3) When we receive the 21st tuple, we will forcefully crash this operator.', "\n";
   print '	// ', "\n";
   print '	// 4) After recovery, everything should proceed normally.', "\n";
   print '	//', "\n";
   print '	// 5) When the final punctuation arrives, in the punctuation processing method below,', "\n";
   print '	//    all the stored results in the local state variables will be sent at once.', "\n";
   print '	//', "\n";
   print '	// 6) User can check the final results to see if there are no gaps in the results due to', "\n";
   print '	//    the operator failure and recovery process.', "\n";
   print '	//', "\n";
   print '	//', "\n";
   print '	// If the newly arrived tuple is the 21st tuple, then we will forcefully crash this operator.', "\n";
   print '		if ((tupleCnt == 20) && (SPL::Functions::Utility::getRelaunchCount() == 0)) {', "\n";
   print '		SPL::Functions::Utility::abort("", 0);', "\n";
   print '	}', "\n";
   print '	', "\n";
   print '	tupleCnt++;', "\n";
   print '	', "\n";
   print '	int32_t _result = 0;', "\n";
   print '	int32_t _x = tuple.getAttributeValue(0);', "\n";
   print '	int32_t _y = tuple.getAttributeValue(1);', "\n";
   print '	string _operation = tuple.getAttributeValue(2);', "\n";
   print '	// Perform the requested operation and compute the result.', "\n";
   print '	if (_operation == "add") {', "\n";
   print '		_result = _x + _y;', "\n";
   print '	} else if (_operation == "subtract") {', "\n";
   print '		_result = _x - _y;', "\n";
   print '	} else if (_operation == "multiply") {', "\n";
   print '		_result = _x * _y;', "\n";
   print '	} else if (_operation == "divide") {', "\n";
   print '		_result = _x / _y;', "\n";
   print '	}', "\n";
   print '	', "\n";
   print '	// Save the results in our local state (member) variables. We are done.', "\n";
   print '	// We will not submit any results at this time.', "\n";
   print '	x.push_back(_x);', "\n";
   print '	y.push_back(_y);', "\n";
   print '	operation.push_back(_operation);', "\n";
   print '	result.push_back(_result);', "\n";
   print '    /* ', "\n";
   print '      OPort0Type otuple;', "\n";
   print '      submit(otuple, 0); // submit to output port 0', "\n";
   print '    */', "\n";
   print '}', "\n";
   print "\n";
   print '// Punctuation processing', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Punctuation const & punct, uint32_t port)', "\n";
   print '{', "\n";
   print '	  // If you participate in a consistent region, you will not even get a FinalMarker.', "\n";
   print '	  // Hence, use the window marker.', "\n";
   print '      if(punct==Punctuation::WindowMarker) {', "\n";
   print '		// This is the end of all tuple processing.', "\n";
   print '		// Let us now submit all the calculation results.', "\n";
   print '		OPort0Type oTuple;', "\n";
   print '		', "\n";
   print '		for (int32_t cnt = 0; cnt < tupleCnt; cnt++) {', "\n";
   print '			// This is the request sequence number attribute.', "\n";
   print '			ValueHandle handle0 = oTuple.getAttributeValue(0);', "\n";
   print '			int32 & sequence = handle0;', "\n";
   print '			sequence = cnt+1;', "\n";
   print '			', "\n";
   print '			// This is x attribute', "\n";
   print '			ValueHandle handle1 = oTuple.getAttributeValue(1);', "\n";
   print '			int32 & _x = handle1;', "\n";
   print '			_x = x.at(cnt);', "\n";
   print '			', "\n";
   print '			// This is y attribute', "\n";
   print '			ValueHandle handle2 = oTuple.getAttributeValue(2);', "\n";
   print '			int32 & _y = handle2;', "\n";
   print '			_y = y.at(cnt);			', "\n";
   print '			', "\n";
   print '			// This is operation attribute', "\n";
   print '			ValueHandle handle3 = oTuple.getAttributeValue(3);', "\n";
   print '			rstring & _operation = handle3;', "\n";
   print '			_operation = operation.at(cnt);', "\n";
   print '			', "\n";
   print '			// This is result attribute', "\n";
   print '			ValueHandle handle4 = oTuple.getAttributeValue(4);', "\n";
   print '			int32 & _result = handle4;', "\n";
   print '			_result = result.at(cnt);			', "\n";
   print '			', "\n";
   print '			// Send it away.', "\n";
   print '			submit(oTuple, 0);', "\n";
   print '		}', "\n";
   print '		', "\n";
   print '		// We submitted all the calculation results.', "\n";
   print '		// Let us now submit the punctuation marker.', "\n";
   print '		submit(punct, 0);', "\n";
   print '      }', "\n";
   print '}', "\n";
   print "\n";
   print '// To support the consistent regions, this operator must implement the following methods.', "\n";
   if ($isInConsistentRegion) {
   print "\n";
   print "\n";
   print '// Drain any pending tuples.', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::drain()', "\n";
   print '{', "\n";
   print '	// Do nothing.', "\n";
   print '}', "\n";
   print "\n";
   print '// Persist state to shared file system', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::checkpoint(Checkpoint & ckpt)', "\n";
   print '{', "\n";
   print '    ckpt << x << y << operation << result << tupleCnt << "\\n";', "\n";
   print '}', "\n";
   print "\n";
   print '// Restore state from shared file system', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::reset(Checkpoint & ckpt)', "\n";
   print '{', "\n";
   print '	// We must be coming back after a crash.', "\n";
   print '    ckpt >> x >> y >> operation >> result >> tupleCnt;', "\n";
   print '}', "\n";
   print "\n";
   print '// Sets operator state to its initial state', "\n";
   print '// This is needed only when there is a crash anywhere in the application before the', "\n";
   print '// very first checkpoint is done.', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::resetToInitialState()', "\n";
   print '{', "\n";
   print '	tupleCnt = 0;', "\n";
   print '}', "\n";
   }
   print "\n";
   print "\n";
   SPL::CodeGen::implementationEpilogue($model);
   print "\n";
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
