
extends Reference


# @const  Callback
const Callback = preload('../vendor/quentincaffeino/callback/src/Callback.gd')

# @var  { [event: string]: { [callbackName: string]: Callback } }
var _observers = {}


# Subscribe to an event
# @param  string  event
# @param  Object  target
# @param  string  name
func sub(event, target, name):  # bool
  var callbackType = Callback.canCreate(target, name)
  if callbackType == Callback.UNKNOWN:
    print('QC/Event/EventObserver: sub: Can\'t initialize callback for event ' + str(event))
    return false

  if !_observers.has(event):
    _observers[event] = {}

  var observerName = target.name + '.' + name
  if !_observers[event].has(observerName):
    _observers[event][observerName] = Callback.new(target, name, callbackType)

  return true


# @param  string  event
# @param  Object  target
# @param  string  name
func unsub(event, target, name):  # void
  var observerName = target.name + '.' + name
  _unsub(event, observerName)


# @param  string  event
# @param  string  observerName
func _unsub(event, observerName):
  if _observers[event].has(observerName):
    _observers[event].erase(observerName)


# @param  string          event
# @param  Variant[]  argv
func emit(event, argv = []):  # bool
  if !_observers.has(event):
    return false

  for o in _observers[event]:
    # Check if event observer still exists,
    # otherwise unsubscribe it
    if _observers[event][o].ensure():
      _observers[event][o].call(argv)
    else:
      _unsub(event, o)

  return true
