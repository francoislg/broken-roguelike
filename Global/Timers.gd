extends Node

func initTimer(newTimer: Timer, timerName: String, waitTime: float, onTimerEndFunction: Callable):
	newTimer.name = timerName
	newTimer.wait_time = waitTime
	newTimer.connect("timeout", onTimerEndFunction)
	return newTimer

func initOneShotTimer(newTimer: Timer, timerName: String, waitTime: float, onTimerEndFunction: Callable):
	newTimer.one_shot = true
	return initTimer(newTimer, timerName, waitTime, onTimerEndFunction)
