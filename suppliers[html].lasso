[
	lassoapp_include_current('/common/menu.lasso')

	local(action = string, feedback = string)

	local(
		sk			= 0,
		limit		= 20
	)
	/* ========================================================
		generic skip set
	======================================================== */
	if(web_request->param('sk')->asString->size) => { 
		#sk = integer(web_request->param('sk')->asString)
		$sv_skips->insert('asset_suppliers' = #sk)
	else 
		#sk = integer($sv_skips->find('asset_suppliers'))
	}
	
]
<h2 class="l">Suppliers List</h2>
</header>
<p class="dialog">Note: Suppliers are managed in the main Mergini Admin</p>

<div class="feedback[#feedback->size ? ' attn']">[#feedback]</div>
<table class="admin">
	<thead>
		<tr>
			<th>Name</th>
			<th>Contact</th>
			<th>Phone</th>
			<th>Email</th>
		</tr>
	</thead>
	<tbody id="assetlistlist">
[
local(thelist = merginiCompany->list, found = 0)
	with t in #thelist where #t->status and #t->issupplier do => { #found += 1 }

if(#found) => {^
	with t in #thelist
	where #t->status and #t->issupplier 
	skip integer($sv_skips->find('asset_suppliers')) take #limit do => {^
		
]
		<tr id="location_number[#t->ide]">
			<td>[#t->name]</td>
			<td>[#t->contact]</td>
			<td>[#t->phone][#t->extn->size ? ' x'+#t->extn]</td>
			<td><a href="mailto:[#t->email]">[#t->email]</a></td>
		</tr>
[
	^}
	else
	]
		<tr>
			<td colspan="4">No suppliers configured.</td>
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
	-found				= #found,
	-maxrecords			= #limit,
	-skip				= integer($sv_skips->find('asset_suppliers')),
	-shownfirst			= integer($sv_skips->find('asset_suppliers'))+1,
	-shownlast			= (integer($sv_skips->find('asset_suppliers'))+#limit <= #found ? integer($sv_skips->find('asset_suppliers'))+#limit | #found),
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