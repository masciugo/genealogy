module Genealogy
  class OptionException < RuntimeError;  end
  class LineageGapException < RuntimeError;  end
  class IncompatibleObjectException < RuntimeError;  end
  class WrongSexException < RuntimeError;  end
  class InfiniteLoopException < RuntimeError;  end
end