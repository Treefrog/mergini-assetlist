[
	lassoapp_include_current('/common/menu.lasso')

	local(action = string, feedback = string)
	web_request->params->asStaticArray >> 'add' ? #action = 'add'
	web_request->params->asStaticArray >> 'edit' ? #action = 'edit'
	web_request->params->asStaticArray >> 'save' ? #action = 'save'

	local(
		sk			= 0,
		limit		= 20
	)
	/* ========================================================
		generic skip set
	======================================================== */
	if(web_request->param('sk')->asString->size) => { 
		#sk = integer(web_request->param('sk')->asString)
		$sv_skips->insert('asset_locationslist' = #sk)
	else 
		#sk = integer($sv_skips->find('asset_locationslist'))
	}

	
	
	local(this = asset_location)
	if(#action == 'save') => {
		if(web_request->param('id')->asString->size) => {
			#this->idde(web_request->param('id')->asString)
			protect => { #this->load }
		}
		protect => {
			handle_error => {
				#this->id == 0 ? #action = 'add' | #action = 'edit'
				#feedback = error_msg
			}
			fail_if(not web_request->param('name')->asString->size,'Please enter a valid location name')
			
			#this->name = web_request->param('name')->asString
			
			#this->save
			#action = string
		}
	else(#action == 'edit')
		if(web_request->param('id')->asString->size) => {
			#this->idde(web_request->param('id')->asString)
			protect => { #this->load }
		}
		protect => {
			handle_error => {
				#feedback = error_msg
				#action = string
			}
			fail_if(not #this->id > 0,'Invalid ID')
		}
	}
]
[if(not #action->size) => {^]
<h2 class="l">Asset Locations <a href="?add" class="small pl">Add <span class="icon-square_plus"></span></a></h2>
</header>

<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
<table class="admin">
	<thead>
		<tr>
			<th>Name</th>
			<th colspan="3">Actions</th>
		</tr>
	</thead>
	<tbody id="locationlist">
[
local(thelist = asset_location->list(false), found = 0)
with t in #thelist skip integer($sv_skips->find('asset_locationslist')) take #limit do => {^
	#found += 1

]
		<tr id="location_number[#t->ide]">
			<td>[#t->name]</td>
			<td>
				<a href="#" identity="[#t->ide]" class="locationstatus">[#t->status ? '<span class="icon-icon-checked small"></span><span class="check_label">Active</span>' | '<span class="icon-icon-unchecked small"></span><span class="check_label">Inactive</span>']</a>
			</td>
			<td>
				<span class="tooltip" aria-label="Edit">
					<a href="?edit&id=[#t->ide]"><span class="icon-square_edit small edit" identity="[#t->ide]"></span></a>
				</span>
			</td>
			<td>
				<span class="tooltip" aria-label="Delete">
					<span class="icon-trash-icon small delete" identity="[#t->ide]"></span>
				</span>
			</td>
		</tr>
[^}
if(not #found) => {^
	]
		<tr>
			<td colspan="5">No locations configured.</td>
		</tr>

[
^}
]
	</tbody>
</table>
<div class="pager row">[
mergini_pageThrough(
	-base				= '',
	-found				= #thelist->size,
	-maxrecords			= #limit,
	-skip				= integer($sv_skips->find('asset_locationslist')),
	-shownfirst			= integer($sv_skips->find('asset_locationslist'))+1,
	-shownlast			= (integer($sv_skips->find('asset_locationslist'))+#limit <= #thelist->size ? integer($sv_skips->find('asset_locationslist'))+#limit | #thelist->size),
	-divider			= '',
	-ShowingClass		= 'pager-counter',
	-PagerNavClass		= '',
	-prevClass			= 'LEAP_prev-link ',
	-prevGroupClass		= 'LEAP_prev-link pagera',
	-nextClass			= 'LEAP_next-link pagera',
	-nextGroupClass		= 'LEAP_next-link pagera'
	)
]</div>

[else(#action == 'edit')]
<h3>Edit Location</h3>
</header>
<form action="?save" class="multi beside" method="post">
	<input type="hidden" name="id" value="[#this->ide]">
	<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
	<fieldset>
		<label for="new_location_name">Location Name</label>
		<input type="text" name="name" placeholder="Enter Location Name" value="[#this->name]">
	</fieldset>
	<fieldset class="form-actions panel">
		<button type="submit">Save</button>
		<button type="button" class="cancel" onClick="document.location.href='?'">Cancel</button>
	</fieldset>
</form>
[else(#action == 'add')]
<h3>Add Location</h3>
</header>
<form action="?save" class="multi beside" method="post">
	<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
	<fieldset>
		<label for="new_location_name">Location Name</label>
		<input type="text" name="name" placeholder="Enter New Location Name" value="[#this->name]">
	</fieldset>
	<fieldset class="form-actions panel">
		<button type="submit">Save</button>
		<button type="button" class="cancel" onClick="document.location.href='?'">Cancel</button>
	</fieldset>
</form>
[^}]