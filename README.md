# TaskForce

_TaskForce_ is an implementation of some of the ideas presented in the [2015
WWDC session "Advanced NSOperations"][advanced-nsop]. Most ideas are implemented
except for mutually exclusive operations. _TaskForce_ replaces `Operation` with
a subclass called `Task` and `OperationQueue` with a subclass called
`TaskQueue`. `TaskQueue` is functionally almost identical to `OperationQueue`
except for the addition of a delegate. `Task`s function a little bit differently
to `Opreation`s and the differences are documented in `Task.swift`.

[advanced-nsop]: https://developer.apple.com/videos/play/wwdc2015/226/
