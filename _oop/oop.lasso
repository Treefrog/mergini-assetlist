[
	define mergini_asset => type {
		parent merginiItem
		data
			protected appid::string			= 'assetlist',		// identifier for app. ideally make same as appname
			protected vartype::string			= 'asset',			// identifier for your item type
			/* ===============================================================================
			options map defines attributes available to the item, 
			plus their datatype and default value
			- Camel case the attribute name to create a human readable name when called like:
				mergini_asset->attrName('nextMaintenanceDate')
			- underscores will also convert to spaces in output of attrName method.
			=============================================================================== */
			public options::map				= map(
												'serial' 				= pair('text' 	= ''), 
												'purchaseDate' 			= pair('date' 	= date), 
												'purchaseCost' 			= pair('dec' 	= 0.00), 
												'replacementValue' 		= pair('dec' 	= 0.00), 
												'assignedTo'			= pair('int' 	= 0),
												'location' 				= pair('int' 	= 0),
												'qty' 					= pair('int' 	= 1),
												'notes' 				= pair('text' 	= ''), 
												
												'deprecationFactor' 	= pair('dec' 	= 0.00), 
												'serviceProvider'		= pair('int' 	= 0),
												'supplier' 				= pair('int' 	= 0),
												
												//'photo' 				= pair('var' 	= ''), // url
												'specs' 				= pair('text' 	= ''), 
												'colour' 				= pair('var' 	= ''), 
												
//												'nextMaintenanceDate' 	= pair('date' 	= date), 
//												'nextMaintenanceNote'	= pair('text' 	= ''), 
//												'maintenancePolicy' 	= pair('text' 	= ''),
//												'insurancePolicy' 		= pair('text' 	= ''), 
//												 
//												'disposedOf' 			= pair('int' 	= 0),
//												'disposedOfDate' 		= pair('date' 	= date),
//												'disposedOfNotes' 		= pair('text' 	= ''), 
//												'disposedOfType' 		= pair('var' 	= '')
												)
		// maintenance record - linked table
		// do later
		
		
		protected attrNameExceptions(txt::string) => {
			not #txt->size ? return
			return map(
				'qty' = 'QTY'
				)->find(#txt)
		}
		public filter(-location::integer=-1,-assignedTo::integer=-1,-cat::integer=-1,-txt::string='') => {
			#location < 0 && #assignedto < 0 && #cat < 0 && not #txt->size ? return ..list(false)
			local(list = ..list(false))
			#location >= 0 ? #list = (with n in #list where integer(#n->location) == #location select #n)->asStaticArray
			#assignedto >= 0 ? #list = (with n in #list where integer(#n->assignedto) == #assignedto select #n)->asStaticArray
			#cat >= 0 ? #list = (with n in #list where integer(#n->cat) == #cat select #n)->asStaticArray
			#txt->size ? #list = (with n in #list where #n->name >> #txt select #n)->asStaticArray
			return #list
		}	
	}

	
	
	
	define asset_location => type {
		trait { 
			import std_common
			import utility_flip
			import utility_web
			import utility_ide
			import utility_select
			import std_pwd
			import std_log
			import std_delete
		}
		data
			protected tablename				= 'asset_location',
			protected namecol				= 'name',
			protected salty					= 'domainusem3now55',
			protected memberarray			= array('id','name','status'),
			
			public id::integer 				= 0,
			public name::string				= string,
			public status::boolean			= false,
			
			protected ideImpl::string			= string
			
		/* ====================================================================================
			list all method
		==================================================================================== */
		public list(onlyactive::boolean=true) => { 
			local(
				sort		= 'name',
				order		= 'ASC',
				filter		= 'WHERE t.status = 1',
				out			= array
			)
			not #onlyactive ? #filter = string
			local(result = mergini_ds->sql('
				SELECT t.*
				FROM '+.tablename+' AS t 
				'+#filter+'
				ORDER BY '+#sort+' '+#order
				,-1))
			with row in #result->rows do => {
				local(obj = asset_location)
				#obj->id					= integer(#row(::id))
				#obj->name 					= #row(::name)->asString
				#obj->status 				= boolean(#row(::status))
				
				#out->insert(#obj)
			}
			return #out
		} // end list method
		public load() => {
			.id == 0 ? return
			local(result = mergini_ds->sql('SELECT * FROM '+.tablename+' WHERE id = '+.id+' LIMIT 1'))
			with row in #result->rows do => {
				local(obj = asset_location)
				.name 					= #row(::name)->asString
				.status 				= boolean(#row(::status))
			}
		}
		
		/* ====================================================================================
			save method
		==================================================================================== */
		public save() => {
			if(not .id) => {
				protect => {
					handle_error => { .errorSet('Asset Location add error',error_code,error_msg,-log) }
					dsinline(-database=mergini_db,-SQL='
						INSERT INTO '+.tablename+'
						SET 
							name				= "'+.name->encodeSQL+'",
							status				= 1'
					) => {
						error_code > 0 ? .errorSet('Asset Location add error',error_code,-detail=error_msg,-log)					
					}
				}
			else
				dsinline(-database=mergini_db,-SQL='
					UPDATE '+.tablename+'
					SET 
						name				= "'+.name->encodeSQL+'"
					WHERE id = '+.id+'
					LIMIT 1'
					) => {
					error_code > 0 ? .errorSet('Asset Location update error',error_code,-detail=error_msg,-log)	
				}
			} // end insert or update if
		} // end save method
		
	}
	define locationCache => type {
		data
			private this::map = map
			
		public lookup(id::integer) => {
			not #id ? return ''
			.this->keys >> #id ? return .this->find(#id)
			with n in mergini_ds->sql('SELECT name FROM asset_location WHERE id = '+#id+' LIMIT 1')->rows do => {
				.this->insert(#id = #n(::name))
				return #n(::name)
			}
			return '' // none found by this point
		}
	}	
	
	define asset_cat => type {
		trait { 
			import std_common
			import utility_flip
			import utility_web
			import utility_ide
			import utility_select
			import std_pwd
			import std_log
			import std_delete
		}
		data
			protected tablename				= 'asset_cat',
			protected namecol				= 'name',
			protected salty					= 'domainusem3now5cat5',
			protected memberarray			= array('id','name','attr','depr','status'),
			
			public id::integer 				= 0,
			public name::string				= string,
			public attr::array				= array,
			public depr::decimal			= 0.00,
			public status::boolean			= false,
			
			protected ideImpl::string			= string
			
		/* ====================================================================================
			list all method
		==================================================================================== */
		public list(onlyactive::boolean=true) => { 
			local(
				sort		= 'name',
				order		= 'ASC',
				filter		= 'WHERE t.status = 1',
				out			= array
			)
			not #onlyactive ? #filter = string
			local(result = mergini_ds->sql('
				SELECT t.*
				FROM '+.tablename+' AS t 
				'+#filter+'
				ORDER BY '+#sort+' '+#order
				,-1))
			with row in #result->rows do => {
				local(obj = asset_cat)
				#obj->id					= integer(#row(::id))
				#obj->name 					= #row(::name)->asString
				protect => { 
					#obj->attr 				= json_deserialize(#row(::attr)->asString)
				}
				#obj->depr					= decimal(#row(::depr))
				#obj->status 				= boolean(#row(::status))
				
				#out->insert(#obj)
			}
			return #out
		} // end list method
		public load() => {
			.id == 0 ? return
			local(result = mergini_ds->sql('SELECT * FROM '+.tablename+' WHERE id = '+.id+' LIMIT 1'))
			with row in #result->rows do => {
				local(obj = asset_cat)
				.name 					= #row(::name)->asString
				protect => { 
					.attr 				= json_deserialize(#row(::attr)->asString)
				}
				.depr					= decimal(#row(::depr))
				.status 				= boolean(#row(::status))
			}
		}
		
		/* ====================================================================================
			save method
		==================================================================================== */
		public save() => {
			if(not .id) => {
				protect => {
					handle_error => { .errorSet('Asset add error',error_code,error_msg,-log) }
					dsinline(-database=mergini_db,-SQL='
						INSERT INTO '+.tablename+'
						SET 
							name				= "'+.name->encodeSQL+'",
							attr				= "'+json_serialize(.attr)->encodeSQL+'",
							depr				= "'+.depr+'",
							status				= 1'
					) => {
						error_code > 0 ? .errorSet('Asset add error',error_code,-detail=error_msg,-log)					
					}
				}
			else
				dsinline(-database=mergini_db,-SQL='
					UPDATE '+.tablename+'
					SET 
						name				= "'+.name->encodeSQL+'",
						attr				= "'+json_serialize(.attr)->encodeSQL+'",
						depr				= "'+.depr+'"
					WHERE id = '+.id+'
					LIMIT 1'
					) => {
					error_code > 0 ? .errorSet('Asset update error',error_code,-detail=error_msg,-log)	
				}
			} // end insert or update if
		} // end save method
		
	}
	
]