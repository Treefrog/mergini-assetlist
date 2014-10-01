[

	/* ========================================================================================
		Init file for mergini app
	======================================================================================== */
	
	protect => {
		handle_error => { log_critical('Asset List load error: '+error_msg+'... '+error_stack) }
		not merginiApp->isInstalled('assetlist') ? 
			merginiApp->install(
				-appid			= 'assetlist',
				-appname		= 'Asset List',
				-description	= 'Asset List Management.',
				-publisher		= 'Treefrog Inc.',
				-apptype		= 'native',
				-aswrapper		= true
			)
		lassoapp_include_current('_oop/oop.lasso')
	}

]