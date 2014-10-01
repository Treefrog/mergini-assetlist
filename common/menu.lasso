[
	local(appname = 'assetlist')

//	Loading javascript after jquery
	$loadJavascriptInFoot->insert(lassoapp_link('/js/app.js'))
	
	session_addVar($gv_SessionName, 'sv_assetfilter')
	var(sv_assetfilter)->isNotA(::map) 	? var(sv_assetfilter 		= map('txt' = string, 'location' = -1, 'assignedTo' = -1, 'cat' = -1))
	
	if(web_request->params->asStaticArray >> 'search') => {
		$sv_assetfilter = map('txt' = string, 'location' = -1, 'assignedTo' = -1, 'cat' = -1) // back to default
		web_request->params->asStaticArray >> 'filter_txt' ? 		$sv_assetfilter->insert('txt' = web_request->param('filter_txt')->asString)
		web_request->params->asStaticArray >> 'filter_location' ? 	$sv_assetfilter->insert('location' = integer(web_request->param('filter_location')->asString))
		web_request->params->asStaticArray >> 'filter_assignedTo' ? $sv_assetfilter->insert('assignedTo' = integer(web_request->param('filter_assignedTo')->asString))
		web_request->params->asStaticArray >> 'filter_cat' ? 		$sv_assetfilter->insert('cat' = integer(web_request->param('filter_cat')->asString))
	}

	
	
//
//	session_addVar($gv_SessionName, 'sv_rank_checkhost')
//	var(sv_rank_checkhost)->isNotA(::string) 	? var(sv_rank_checkhost 				= 'com')
//
//	session_addVar($gv_SessionName, 'sv_rank_usekeywords')
//	var(sv_rank_usekeywords)->isNotA(::array) 	? var(sv_rank_usekeywords 				= array)
//
//	session_addVar($gv_SessionName, 'sv_rank_currentkeyword')
//	var(sv_rank_currentkeyword)->isNotA(::integer) 	? var(sv_rank_currentkeyword 		= 0)
//	
//	session_addVar($gv_SessionName, 'sv_rank_usecompetitors')
//	var(sv_rank_usecompetitors)->isNotA(::array) 	? var(sv_rank_usecompetitors 		= array)
//
//	session_addVar($gv_SessionName, 'sv_rank_useengines')
//	var(sv_rank_useengines)->isNotA(::array) 	? var(sv_rank_useengines 		= array)
//
//	
//	session_addVar($gv_SessionName, 'sv_rank_range1')
//	var(sv_rank_range1)->isNotA(::date) 	? var(sv_rank_range1 		= date((date->year - 1)+'-01-01'))
//	
//	session_addVar($gv_SessionName, 'sv_rank_range2')
//	var(sv_rank_range2)->isNotA(::date) 	? var(sv_rank_range2 		= date)
//
//	
//	web_request->param('use')->asString->size ? 
//		$sv_rank_currentdomain = integer(web_request->param('use')->asString)
//		
//	web_request->param('withhost')->asString->size ? 
//		$sv_rank_checkhost = web_request->param('withhost')->asString
//
//	web_request->param('usekeyword')->asString->size ? 
//		$sv_rank_currentkeyword = integer(web_request->param('usekeyword')->asString)
//				
//	web_request->param('use')->asString->size ? $sv_rank_usekeywords = array
//		
//	web_request->param('selectsnapshotdate1')->asString->size ?
//		$sv_rank_range1 = date(web_request->param('selectsnapshotdate1')->asString)
//	web_request->param('selectsnapshotdate2')->asString->size ?
//		$sv_rank_range2 = date(web_request->param('selectsnapshotdate2')->asString)
//
//	if(web_request->params->asStaticArray >> 'usekeywords') => {
//		$sv_rank_usekeywords = array
//		with p in web_request->params->asStaticArray where #p->first == 'usekeywords' let k = #p->second do => { integer(#k) > 0 ? $sv_rank_usekeywords->insert(integer(#k)) }
//	}
//	if(web_request->params->asStaticArray >> 'usecompetitors') => {
//		$sv_rank_usecompetitors = array
//		with p in web_request->params->asStaticArray where #p->first == 'usecompetitors' let k = #p->second do => { integer(#k) > 0 ? $sv_rank_usecompetitors->insert(integer(#k)) }
//	}
//	if(web_request->params->asStaticArray >> 'useengines') => {
//		$sv_rank_useengines = array
//		with p in web_request->params->asStaticArray where #p->first == 'useengines' let k = #p->second do => { #k->size ? $sv_rank_useengines->insert(#k) }
//	}

]

<header class="row">
<h1><div class="app_icon"><img src="[lassoapp_link('/icon.svg')]"></div> Asset List</h1>
<nav class="rb ra mb">
	<ul class="mainnav horizontal">
		<li><a href="[mergini_apphome][#appname]"><span class="icon-home small"></span></a></li>
		<li><a href="[mergini_apphome][#appname]/categories" class="mr ml">Categories</a></li>
		<li><a href="[mergini_apphome][#appname]/locations" class="mr ml">Locations</a></li>
		<li><a href="[mergini_apphome][#appname]/suppliers" class="ml">Suppliers</a></li>
	</ul>
</nav>