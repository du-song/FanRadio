install:
	rake dmg
	rake feed
	cp appcast/build/FanRadio-* appcast/build/appcast.xml /Users/freewizard/Projects/AppEngine/rollingcode/static/app/fanradio 
