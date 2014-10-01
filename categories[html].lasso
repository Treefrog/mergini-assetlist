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
		$sv_skips->insert('asset_categorylist' = #sk)
	else 
		#sk = integer($sv_skips->find('asset_categorylist'))
	}

	
	
	local(this = asset_cat)
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
			fail_if(not web_request->param('name')->asString->size,'Please enter a valid asset category name')
			
			#this->name = web_request->param('name')->asString
			#this->depr = decimal(web_request->param('depr')->asString)
			
			#this->attr = array
			with test in web_request->params->asStaticArray
			where #test->isa(::pair) && #test->first >> 'attr'
			do => { #this->attr->insert(#test->value->asString) }

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
<h2 class="l">Asset Categories <a href="?add" class="small pl">Add <span class="icon-square_plus"></span></a></h2>
</header>

<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
<table class="admin">
	<thead>
		<tr>
			<th>Name</th>
			<th colspan="3">Actions</th>
		</tr>
	</thead>
	<tbody id="assetcatlist">
[
local(thelist = asset_cat->list(false))
if(#thelist->size) => {^
	with t in #thelist skip integer($sv_skips->find('asset_categorylist')) take #limit do => {^

]
		<tr id="cat_number[#t->ide]">
			<td>[#t->name]</td>
			<td>
				<a href="#" identity="[#t->ide]" class="catstatus">[#t->status ? '<span class="icon-icon-checked small"></span><span class="check_label">Active</span>' | '<span class="icon-icon-unchecked small"></span><span class="check_label">Inactive</span>']</a>
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
			<td colspan="5">No categories configured.</td>
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
	-skip				= integer($sv_skips->find('asset_categorylist')),
	-shownfirst			= integer($sv_skips->find('asset_categorylist'))+1,
	-shownlast			= (integer($sv_skips->find('asset_categorylist'))+#limit <= #thelist->size ? integer($sv_skips->find('asset_categorylist'))+#limit | #thelist->size),
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
[else(#action == 'edit')]
<h3>Edit Category</h3>
</header>
<form action="?save" class="multi beside" method="post">
	<input type="hidden" name="id" value="[#this->ide]">
	<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
	<fieldset>
		<label for="new_asset_name">Asset Name</label>
		<input type="text" name="name" placeholder="Enter Asset Name" value="[#this->name]">
	</fieldset>
	<fieldset>
		<label for="new_asset_depr">Default Depreciation %</label>
		<input type="text" name="depr" placeholder="Enter Depreciation %" value="[#this->depr->asString(-precision=2)]">
	</fieldset>
	<fieldset class="radio multi">
		<label for="available_attr">Available Attributes</label>
		<ul>
[with attr in mergini_asset->options->keys do => {^]
			<li><label><input type="checkbox" name="attr" class="custom" value="[#attr]" style="width:auto"[#this->attr >> #attr ? ' checked="checked"']><span></span> [mergini_asset->attrName(#attr)]</label></li>
[^}]
		</ul>
	</fieldset>
	<fieldset class="form-actions panel">
		<button type="submit">Save</button>
		<button type="button" class="cancel" onClick="document.location.href='?'">Cancel</button>
	</fieldset>
</form>
[else(#action == 'add')]
<h3>Add Category</h3>
</header>
<form action="?save" class="multi beside" method="post">
	<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
	<fieldset>
		<label for="new_asset_name">Asset Name</label>
		<input type="text" name="name" placeholder="Enter New Asset Name" value="[#this->name]">
	</fieldset>
	<fieldset>
		<label for="new_asset_depr">Default Depreciation %</label>
		<input type="text" name="depr" placeholder="Enter Depreciation %" value="[#this->depr->asString(-precision=2)]">
	</fieldset>
	<fieldset class="radio multi">
		<label for="available_attr">Available Attributes</label>
		<ul>
[with attr in mergini_asset->options->keys do => {^]
			<li><label><input type="checkbox" name="attr" value="[#attr]" class="custom"[#this->attr >> #attr ? ' checked="checked"']><span></span> [mergini_asset->attrName(#attr)]</label></li>
[^}]
		</ul>
	</fieldset>

	<fieldset class="form-actions panel">
		<button type="submit">Save</button>
		<button type="button" class="cancel" onClick="document.location.href='?'">Cancel</button>
	</fieldset>
</form>
[^}]