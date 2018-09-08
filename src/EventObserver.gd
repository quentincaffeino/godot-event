
extends Reference


# @var  Callback
var _Callback = preload('../vendor/quentincaffeino/callback/src/Callback.gd')

# @var  { [event: string]: { [callback_name: string]: Callback } }
var _observers = {}


# Subscribe to an event
# @param  string  event
# @param  Object  target
# @param  string  name
func sub(event, target, name):  # bool
  if typeof(event) != TYPE_STRING:
    print('QC/Event/EventObserver: sub: Event name must be a string. Provided ' + str(typeof(event)))
    return false

  var callback_type = _Callback.canCreate(target, name)
  if callback_type == _Callback.UNKNOWN:
    print('QC/Event/EventObserver: sub: Can\'t initialize callback for event ' + str(event))
    return false

  if !_observers.has(event):
    _observers[event] = {}

  var observer_name = target.name + '.' + name
  if !_observers[event].has(observer_name):
    _observers[event][observer_name] = _Callback.new(target, name, callback_type)

  return true


# @param  string  event
# @param  Object  target
# @param  string  name
func unsub(event, target, name):  # void
  var observer_name = target.name + '.' + name
  _unsub(event, observer_name)


# @param  string  event
# @param  string  observer_name
func _unsub(event, observer_name):
  if _observers[event].has(observer_name):
    _observers[event].erase(observer_name)


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
