
package OrderedMerger_cpp;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   print '#include <iostream>', "\n";
   print "\n";
   print 'using namespace std;', "\n";
   print "\n";
   SPL::CodeGen::implementationPrologue($model);
   print "\n";
   print "\n";
     use OrderedMergerCommon;                                                                                                                 
     OrderedMergerCommon::verify($model); 
     my $keyExpr = $model->getParameterByName("key")->getValueAt(0);
     my $keyType = $keyExpr->getCppType();
     my $keyValue = $keyExpr->getCppExpression();
     my $bufferSizeParam = $model->getParameterByName("bufferSize");
     my $blocking = (defined($bufferSizeParam)) ? 1 : 0;
     my $bufferSizeValue = ($blocking==1) ? $bufferSizeParam->getValueAt(0)->getCppExpression() : "1000u";
     my $iport = $model->getInputPortAt(0);
     my $ituple = $iport->getCppTupleName();
     my $oport = $model->getOutputPortAt(0);
     my $otupleInit = SPL::CodeGen::getOutputTupleCppInitializer($oport);
   print "\n";
   print "\n";
   print '// Constructor', "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::MY_OPERATOR()', "\n";
   print '{', "\n";
   print '  numDone_ = 0;', "\n";
   print '  blocking_ = ';
   print $blocking;
   print ';', "\n";
   print '  bufferSize_ = max(';
   print $bufferSizeValue;
   print ', 1u);', "\n";
   print '  uint32_t numInputs = getNumberOfInputPorts();', "\n";
   print '  queues_.resize(numInputs);', "\n";
   print '  cvs_.resize(numInputs);', "\n";
   print '}', "\n";
   print "\n";
   print '// Desructor', "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::~MY_OPERATOR()', "\n";
   print '{', "\n";
   print '  uint32_t numInputs = getNumberOfInputPorts();', "\n";
   print '  for (uint32_t i=0; i<numInputs; ++i) {', "\n";
   print '    TupleQueue & queue = queues_[i];', "\n";
   print '    for (size_t j=0, ju=queue.size(); j<ju; ++j)', "\n";
   print '      delete queue[j];', "\n";
   print '  }', "\n";
   print '}', "\n";
   print "\n";
   print '// Tuple processing for non-mutating ports', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple const & tuple, uint32_t port)', "\n";
   print '{', "\n";
   print '  AutoPortMutex apm(mutex_, *this);', "\n";
   print "\n";
   print '  { ', "\n";
   print '    IPort0Type const & ';
   print $ituple;
   print ' = static_cast<IPort0Type const &>(tuple);', "\n";
   print '    KeyType key = ';
   print $keyValue;
   print ';', "\n";
   print '    TupleQueue & queue = queues_[port];', "\n";
   print '    while (blocking_ && queue.size()==bufferSize_)', "\n";
   print '      cvs_[port].wait(mutex_);', "\n";
   print '    // update the next heap if the queue for the channel is empty', "\n";
   print '    if (queue.empty())', "\n";
   print '      nextHeap_.updateItem(key, port);', "\n";
   print '    // create a new copy and add to the proper channel queue', "\n";
   print '    queue.push_back(new IPort0Type(';
   print $ituple;
   print '));', "\n";
   print '    // update the seen heap with the new seq no for the channel ', "\n";
   print '    seenHeap_.updateItem(key, port);', "\n";
   print '  }', "\n";
   print '  ', "\n";
   print '  while (!nextHeap_.empty()) { ', "\n";
   print '    // check if next tuple is ready to be sent', "\n";
   print '    KeyHeap::KeyIdPair const & next = nextHeap_.getTopItem(); ', "\n";
   print '    KeyType const & nextKey = next.key();', "\n";
   print '    uint32_t const & nextPort = next.id();', "\n";
   print '    KeyHeap::KeyIdPair const & seen = seenHeap_.getTopItem(); ', "\n";
   print '    KeyType const & seenKey = seen.key(); ', "\n";
   print '    uint32_t numInputs = getNumberOfInputPorts();', "\n";
   print '    bool steady = (seenHeap_.size() == (numInputs - numDone_));', "\n";
   print '    if (steady && nextKey <= seenKey) { ', "\n";
   print '      // find the right channel and get the tuple', "\n";
   print '      TupleQueue & queue = queues_[nextPort];', "\n";
   print '      auto_ptr<IPort0Type> rtuple(queue.front());', "\n";
   print '      queue.erase(queue.begin());', "\n";
   print '      // update the next heap', "\n";
   print '      if (queue.empty()) {', "\n";
   print '        nextHeap_.removeItem(nextPort);', "\n";
   print '      } else {', "\n";
   print '        IPort0Type const & ';
   print $ituple;
   print ' = *queue.front();', "\n";
   print '        KeyType key = ';
   print $keyValue;
   print ';', "\n";
   print '        nextHeap_.updateItem(key, nextPort);', "\n";
   print '      }', "\n";
   print '      { // send the tuple', "\n";
   print '        IPort0Type & ';
   print $ituple;
   print ' = *rtuple;', "\n";
   print '        OPort0Type otuple(';
   print $otupleInit;
   print ');', "\n";
   print '        submit(otuple, 0);', "\n";
   print '      }', "\n";
   print '      if (blocking_ && queue.size()==bufferSize_-1)', "\n";
   print '        cvs_[nextPort].signal();', "\n";
   print '    } else break;', "\n";
   print '  }', "\n";
   print '}', "\n";
   print "\n";
   print '// Punctuation processing', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Punctuation const & punct, uint32_t port)', "\n";
   print '{', "\n";
   print '  if(punct!=Punctuation::FinalMarker)', "\n";
   print '    return;', "\n";
   print '  ', "\n";
   print '  AutoPortMutex apm(mutex_, *this);', "\n";
   print '  numDone_++;', "\n";
   print '  seenHeap_.removeItem(port);', "\n";
   print '  uint32_t numInputs = getNumberOfInputPorts();', "\n";
   print '  if (numDone_==numInputs) {', "\n";
   print '    while (!nextHeap_.empty()) {', "\n";
   print '      KeyHeap::KeyIdPair const & next = nextHeap_.getTopItem(); ', "\n";
   print '      KeyType const & nextKey = next.key();', "\n";
   print '      uint32_t const & nextPort = next.id();', "\n";
   print '      TupleQueue & queue = queues_[nextPort];', "\n";
   print '      auto_ptr<IPort0Type> rtuple(queue.front());', "\n";
   print '      queue.erase(queue.begin());', "\n";
   print '      // update the next heap', "\n";
   print '      if (queue.empty()) {', "\n";
   print '        nextHeap_.removeItem(nextPort);', "\n";
   print '      } else {', "\n";
   print '        IPort0Type const & ';
   print $ituple;
   print ' = *queue.front();', "\n";
   print '        KeyType key = ';
   print $keyValue;
   print ';', "\n";
   print '        nextHeap_.updateItem(key, nextPort);', "\n";
   print '      }', "\n";
   print '      { // send the tuple', "\n";
   print '        IPort0Type & ';
   print $ituple;
   print ' = *rtuple;', "\n";
   print '        OPort0Type otuple(';
   print $otupleInit;
   print ');', "\n";
   print '        submit(otuple, 0);', "\n";
   print '      }', "\n";
   print '      if (blocking_ && queue.size()==bufferSize_-1)', "\n";
   print '        cvs_[port].signal();', "\n";
   print '    }', "\n";
   print '  } ', "\n";
   print '}', "\n";
   print "\n";
   SPL::CodeGen::implementationEpilogue($model);
   print "\n";
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
