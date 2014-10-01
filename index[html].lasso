[
	lassoapp_include_current('/common/menu.lasso')

	local(action = string, feedback = string, nameCache = merginiNameCache, locationCache = locationCache)
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
		$sv_skips->insert('asset_list' = #sk)
	else 
		#sk = integer($sv_skips->find('asset_list'))
	}

	
	
	local(this = mergini_asset)
	if(#action == 'save') => {
		if(web_request->param('id')->asString->size) => {
			#this->idde(web_request->param('id')->asString)
			protect => { #this->load }
		}
		protect => {
			handle_error => {
				#this->id == 0 ? #action = 'add' | #action = 'edit'
				#feedback = error_msg
				#feedback->append('<pre>'+error_stack+'</pre>') // uncomment this line for debug
			}
			fail_if(not web_request->param('name')->asString->size,'Please enter a valid asset name')
			
			#this->name = web_request->param('name')->asString
			
			#this->cat = integer(web_request->param('cat')->asString)
			fail_if(not #this->cat,'Please enter a valid category')
			
			local(thiscat = asset_cat)
			#thiscat->id = #this->cat
			#thiscat->load
			with attr in #thiscat->attr do => {
				local(item = string)
				protect => {
					handle_error => {
						#item = web_request->param('attr_'+#attr)->asString
					}
					//log_critical(#this->options->find(#attr)+' = '+#this->options->find(#attr)->first)
					match(#this->options->find(#attr)->first) => {
						case('int')
							#item = integer(web_request->param('attr_'+#attr)->asString)
						case('dec')
							#item = decimal(web_request->param('attr_'+#attr)->asString)
						case('date')
							#item = date(web_request->param('attr_'+#attr)->asString)
						case
							#item = web_request->param('attr_'+#attr)->asString
					}

				}
				#this->setAttribute(#attr,#item)
			}
			
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
<h2 class="l">Asset List <a href="?add" class="small pl">Add <span class="icon-square_plus"></span></a></h2>
</header>

<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
<form action="?search" method="post" class="multi beside cfx">
<div class="form-wrap row rounded">
	<div class="row">
		<div class="col two-thirds first">
			<fieldset>
				<label>Filter:</label>
				<input type="text" name="filter_txt" value="[$sv_assetfilter->find('txt')]" placeholder="Search" class="full">
				<button class="icon" type="reset"><span class="icon-close-icon"></span></button>
			</fieldset>
		</div>
		
		<div class="col one-third last">
			<fieldset class="form-actions">
				<input type="Submit" value="Search"> <input type="button" class="sendto reset" location="?search" value="Reset">
			</fieldset>
		</div>
	</div>
	<div class="col one-third first">
		<fieldset>
			<label>Location:</label>
			<div class="styled_select inline">
				<select name="filter_location">
					<option value="-1"[integer($sv_assetfilter->find('location')) < 0 ? ' selected="selected"']>Ignore</option>
					<option value="0"[not integer($sv_assetfilter->find('location')) ? ' selected="selected"']>Unassigned</option>
					[asset_location->selectOptions(integer($sv_assetfilter->find('location')),-status=-1,-showstatus=true)]
				</select>
			</div>
		</fieldset>
	</div>
	<div class="col one-third">
		<fieldset>
			<label>Category:</label>
			<div class="styled_select inline">
				<select name="filter_cat">
					<option value="-1"[integer($sv_assetfilter->find('cat')) < 0 ? ' selected="selected"']>Ignore</option>
					[asset_cat->selectOptions(integer($sv_assetfilter->find('cat')),-status=-1,-showstatus=true)]
				</select>
			</div>
		</fieldset>
	</div>
	
	<div class="col one-third last">
		<fieldset>
			<label>Assigned To:</label>
			<div class="styled_select inline">
				<select name="filter_assignedto">
					<option value="-1"[integer($sv_assetfilter->find('assignedto')) < 0 ? ' selected="selected"']>Ignore</option>
					<option value="0"[not integer($sv_assetfilter->find('assignedto')) ? ' selected="selected"']>Unassigned</option>
					[merginiUser->selectOptions(integer($sv_assetfilter->find('assignedto')),-status=-1,-showstatus=true)]
				</select>
			</div>
		</fieldset>
	</div>

</form>
</div>
<table class="admin">
	<thead>
		<tr>
			<th>Name</th>
			<th>Assigned To</th>
			<th>Location</th>
			<th colspan="3">Actions</th>
		</tr>
	</thead>
	<tbody id="assetlist">
[
local(thelist = mergini_asset->filter(
	-location	= integer($sv_assetfilter->find('location')),
	-assignedto	= integer($sv_assetfilter->find('assignedto')),
	-cat		= integer($sv_assetfilter->find('cat')),
	-txt		= $sv_assetfilter->find('txt')->asString
	)
)
if(#thelist->size) => {^
	with t in #thelist skip integer($sv_skips->find('asset_list')) take #limit do => {^

]
		<tr id="location_number[#t->ide]">
			<td>[#t->name]</td>
			<td>[integer(#t->assignedTo) ? #nameCache->lookup(integer(#t->assignedTo)) | 'Unassigned']</td>
			<td>[integer(#t->location) ? #locationCache->lookup(integer(#t->location)) | 'Unassigned']</td>
			<td>
				<a href="#" identity="[#t->ide]" class="assetstatus">[#t->status ? '<span class="icon-icon-checked small"></span><span class="check_label">Active</span>' | '<span class="icon-icon-unchecked small"></span><span class="check_label">Inactive</span>']</a>
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
[
	^}
	else
	]
		<tr>
			<td colspan="5">No assets configured.</td>
		</tr>

[
^}
]
	</tbody>
</table>
[if(#thelist->size) => {^]
<div class="pager row">[
mergini_pageThrough(
	-base				= '',
	-found				= #thelist->size,
	-maxrecords			= #limit,
	-skip				= integer($sv_skips->find('asset_list')),
	-shownfirst			= integer($sv_skips->find('asset_list'))+1,
	-shownlast			= (integer($sv_skips->find('asset_list'))+#limit <= #thelist->size ? integer($sv_skips->find('asset_list'))+#limit | #thelist->size),
	-divider			= '',
	-ShowingClass		= 'pager-counter',
	-PagerNavClass		= '',
	-prevClass			= 'LEAP_prev-link ',
	-prevGroupClass		= 'LEAP_prev-link pagera',
	-nextClass			= 'LEAP_next-link pagera',
	-nextGroupClass		= 'LEAP_next-link pagera'
	)
]</div>
[^}]
[else(#action == 'edit' || #action == 'add')
	local(firstattrlist = array)
]
<h3>[#action == 'edit' ? 'Edit' | 'Add'] Asset</h3>
</header>
<form action="?save" class="multi beside" method="post">
	[#action == 'edit' ? '<input type="hidden" name="id" value="'+#this->ide+'">']
	<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
	<fieldset>
		<label for="new_asset_name">Asset Name</label>
		<input type="text" name="name" placeholder="Enter Asset Name" value="[#this->name]">
	</fieldset>
	<fieldset>
		<label for="new_asset_name">Category</label>
		<div class="styled_select inline">
			<select name="cat" id="changecats">[with cats in asset_cat->list(false) do =>{^
				not #this->cat && not #firstattrlist->size ? #firstattrlist = #cats->attr
				#this->cat == #cats->id ? #firstattrlist = #cats->attr
]
				<option value="[#cats->id]" attrs="[#cats->attr->join(',')]"[#this->cat == #cats->id ? ' selected="selected"']>[#cats->name]</option>
			[^}]</select>
		</div>
	</fieldset>
	<fieldset class="allattr attr_assignedTo" [#firstattrlist !>> 'assignedTo' ? ' style="display:none;"']>
		<label for="assignedTo">Assigned To</label>
		<div class="styled_select inline">
			<select name="attr_assignedTo">
				<option value="0"[not integer(#this->assignedto) ? ' selected="selected"']>Unassigned</option>
				[merginiUser->selectOptions(integer(#this->assignedto),-status=-1,-showstatus=true)]
			</select>
		</div>
	</fieldset>
	<fieldset class="allattr attr_location" [#firstattrlist !>> 'assignedTo' ? ' style="display:none;"']>
		<label for="assignedto">Physical Location</label>
		<div class="styled_select inline">
			<select name="attr_location">
				<option value="0"[not integer(#this->location) ? ' selected="selected"']>Unassigned</option>
				[asset_location->selectOptions(integer(#this->location),-status=-1,-showstatus=true)]
			</select>
		</div>
	</fieldset>
	<fieldset class="allattr attr_purchaseDate" [#firstattrlist !>> 'purchaseDate' ? ' style="display:none;"']>
		<label for="attr_purchaseDate">Purchase Date (mm/dd/yyyy)</label>
		<input type="text" name="attr_purchaseDate" placeholder="Enter Purchase Date (mm/dd/yyyy)" value="[protect => {^ #this->purchaseDate->format('%m/%d/%yy') ^}]">
	</fieldset>
	<fieldset class="allattr attr_purchaseCost" [#firstattrlist !>> 'purchaseCost' ? ' style="display:none;"']>
		<label for="attr_purchaseCost">Purchase Price ($)</label>
		<input type="text" name="attr_purchaseCost" placeholder="Enter Purchase Price" value="[decimal(#this->purchaseCost)->asString(-precision=2)]">
	</fieldset>
	<fieldset class="allattr attr_replacementValue" [#firstattrlist !>> 'replacementValue' ? ' style="display:none;"']>
		<label for="attr_replacementValue">Replacement Cost ($)</label>
		<input type="text" name="attr_replacementValue" placeholder="Enter Replacement Value" value="[decimal(#this->replacementValue)->asString(-precision=2)]">
	</fieldset>
	<fieldset class="allattr attr_deprecationFactor" [#firstattrlist !>> 'deprecationFactor' ? ' style="display:none;"']>
		<label for="attr_deprecationFactor">Deprecation Factor</label>
		<input type="text" name="attr_deprecationFactor" placeholder="Enter Deprecation Factor" value="[decimal(#this->deprecationFactor)->asString(-precision=2)]">
	</fieldset>
	<fieldset class="allattr attr_serial" [#firstattrlist !>> 'serial' ? ' style="display:none;"']>
		<label for="attr_serial">Serial #</label>
		<input type="text" name="attr_serial" placeholder="Enter Serial Number" value="[#this->serial]">
	</fieldset>
	<fieldset class="allattr attr_qty" [#firstattrlist !>> 'qty' ? ' style="display:none;"']>
		<label for="attr_qty">QTY</label>
		<input type="text" name="attr_qty" placeholder="Enter QTY" value="[#this->qty]">
	</fieldset>
	<fieldset class="allattr attr_notes" [#firstattrlist !>> 'notes' ? ' style="display:none;"']>
		<label for="attr_notes">Notes</label>
		<textarea name="attr_notes">[#this->notes]</textarea>
	</fieldset>
	<fieldset class="allattr attr_supplier" [#firstattrlist !>> 'supplier' ? ' style="display:none;"']>
		<label for="attr_supplier">Supplier</label>
		<div class="styled_select inline">
			<select name="attr_supplier">
				<option value="0"[not integer(#this->supplier) ? ' selected="selected"']>Unassigned</option>
				[merginiCompany->selectOptions(integer(#this->supplier),-status=-1,-showstatus=true)]
			</select>
		</div>
	</fieldset>
	<fieldset class="allattr attr_serviceProvider" [#firstattrlist !>> 'serviceProvider' ? ' style="display:none;"']>
		<label for="attr_serviceProvider">Service Provider</label>
		<div class="styled_select inline">
			<select name="attr_serviceProvider">
				<option value="0"[not integer(#this->serviceProvider) ? ' selected="selected"']>Unassigned</option>
				[merginiCompany->selectOptions(integer(#this->serviceProvider),-status=-1,-showstatus=true)]
			</select>
		</div>
	</fieldset>
	<fieldset class="allattr attr_specs" [#firstattrlist !>> 'specs' ? ' style="display:none;"']>
		<label for="attr_specs">Specifications</label>
		<textarea name="attr_specs">[#this->specs]</textarea>
	</fieldset>
	<fieldset class="allattr attr_colour" [#firstattrlist !>> 'colour' ? ' style="display:none;"']>
		<label for="attr_colour">Color</label>
		<input type="text" name="attr_colour" placeholder="Enter Color" value="[#this->colour]">
	</fieldset>




	<fieldset class="form-actions panel">
		<button type="submit">Save</button>
		<button type="button" class="cancel" onClick="document.location.href='?'">Cancel</button>
	</fieldset>
</form>

[^}]