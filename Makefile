install:
	rake dmg
	rake feed
	cp -L appcast/build/release_notes.html appcast/build/FanRadio.dmg appcast/build/appcast.xml /Users/freewizard/Projects/AppEngine/rollingcode/static/app/fanradio 
