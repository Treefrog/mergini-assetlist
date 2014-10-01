[
	merginiSetup
	$sv_uid == 0 ? redirect_url(mergini_home)
	
	var(json = map)
	local(
			successful	= false,
			feedback	= string,
			sk			= 0,
			limit		= 20,
			list		= array
	)
	
	if(web_request->param('obj')->asString == 'location') => {
		local(this = asset_location)
		$json->insert('target' = 'locationlist')
		$json->insert('columns' = array('id','name','status'))
		local(template = '<tr id="location_number{id}">
			<td>{name}</td>
			<td>
				<a href="#" identity="{id}" class="locationstatus">{status}</a>
			</td>
			<td>
				<span class="tooltip" aria-label="Edit">
					<a href="?edit&id={id}"><span class="icon-square_edit small edit" identity="{id}"></span></a>
				</span>
			</td>
			<td>
				<span class="tooltip" aria-label="Delete">
					<span class="icon-trash-icon small delete" identity="{id}"></span>
				</span>
			</td>
		</tr>
')
		#template->replace('\t','') // there for readability only!
		#template->replace('\n','') // there for readability only!
		$json->insert('template' = #template)
		
		
		/* ========================================================
			generic skip set
		======================================================== */
		if(web_request->param('sk')->asString->size) => { 
			#sk = integer(web_request->param('sk')->asString)
			$sv_skips->insert('asset_locationslist' = #sk)
		else 
			#sk = integer($sv_skips->find('asset_locationslist'))
		}

		
		#this->idde(web_request->param('id')->asString)
		#this->load
		
		if(web_request->params->asStaticArray >> 'delete' && #this->id > 0) => {
			#this->delete
			#successful = true
			#feedback = 'Location deleted successfully.'
			
		else
			local(state = #this->flip(-silent=false))
			#successful = true
			#feedback = 'Location '+(not #state ? 'de')+'activated successfully.'
			
		}

		

		local(thelist = asset_location->list(false))
		with obj in #thelist skip #sk take #limit do => {
			local(n = map)
			#n->insert('id' = #obj->ide)
			#n->insert('name' = #obj->name)
			#n->insert('status' = #obj->status ? '<span class="icon-icon-checked small"></span><span class="check_label">Active</span>' | '<span class="icon-icon-unchecked small"></span><span class="check_label">Inactive</span>')
			#list->insert(#n)
		}		
		$json->insert('rows'= #list)
//		$json->insert('pager'='')
		$json->insert('pager' = mergini_pageThrough(
			-base				= '',
			-found				= #thelist->size,
			-maxrecords			= #limit,
			-skip				= #sk,
			-shownfirst			= #sk+1,
			-shownlast			= (#sk+#limit <= #thelist->size ? #sk+#limit | #thelist->size),
			-divider			= '',
			-ShowingClass		= 'pager-counter groupcount',
			-PagerNavClass		= '',
			-prevClass			= 'LEAP_prev-link pagera',
			-prevGroupClass		= 'LEAP_prev-link pagera',
			-nextClass			= 'LEAP_next-link pagera',
			-nextGroupClass		= 'LEAP_next-link pagera',
			-locationattr		= 'groups'
			)
		)
	else(web_request->param('obj')->asString == 'asset')
		local(this = mergini_asset, nameCache = merginiNameCache, locationCache = locationCache)
		$json->insert('target' = 'assetlist')
		$json->insert('columns' = array('id','name','assignedTo','location','status'))
		local(template = '<tr id="location_number{id}">
			<td>{name}</td>
			<td>{assignedTo}</td>
			<td>{location}</td>
			<td>
				<a href="#" identity="{id}" class="assetstatus">{status}</a>
			</td>
			<td>
				<span class="tooltip" aria-label="Edit">
					<a href="?edit&id={id}"><span class="icon-square_edit small edit" identity="{id}"></span></a>
				</span>
			</td>
			<td>
				<span class="tooltip" aria-label="Delete">
					<span class="icon-trash-icon small delete" identity="{id}"></span>
				</span>
			</td>
		</tr>
')
		#template->replace('\t','') // there for readability only!
		#template->replace('\n','') // there for readability only!
		$json->insert('template' = #template)
		
		
		
		#this->idde(web_request->param('id')->asString)
		#this->load
		
		if(web_request->params->asStaticArray >> 'delete' && #this->id > 0) => {
			#this->delete
			#successful = true
			#feedback = 'Asset deleted successfully.'
			
		else
			local(state = #this->flip(-silent=false))
			#successful = true
			#feedback = 'Asset '+(not #state ? 'de')+'activated successfully.'
		}

		

		local(thelist = mergini_asset->list(false))
		with obj in #thelist do => {
			local(n = map)
			#n->insert('id' = #obj->ide)
			#n->insert('name' = #obj->name)
			#n->insert('assignedTo' = (integer(#obj->assignedTo) ? #nameCache->lookup(integer(#obj->assignedTo)) | 'Unassigned'))
			#n->insert('location' = (integer(#obj->location) ? #locationCache->lookup(integer(#obj->location)) | 'Unassigned'))
			#n->insert('status' = #obj->status ? '<span class="icon-icon-checked small"></span><span class="check_label">Active</span>' | '<span class="icon-icon-unchecked small"></span><span class="check_label">Inactive</span>')
			#list->insert(#n)
		}		
		$json->insert('rows'= #list)
		$json->insert('pager'='')
		
	}
	$json->insert('successful'= #successful)
	$json->insert('feedback'= #feedback)
	local('xout' = json_serialize($json))
	#xout->trim
	#xout
]