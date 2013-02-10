<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="layout" content="main" />
<r:require modules="observations_list" />
<g:set var="entityName"
	value="${message(code: 'observation.label', default: 'Search Results')}" />
<title><g:message code="default.list.label" args="[entityName]" />
</title>
<script type="text/javascript"
	src="http://maps.google.com/maps/api/js?sensor=true"></script>
</head>
<body>

	<div class="span12">
		<clist:showSubmenuTemplate model="['entityName':entityName]" />
		<search:searchResultsHeading />
		<uGroup:rightSidebar />
		<!-- main_content -->
			<div id="searchResults" class="list"
				style="margin-left: 0px; clear: both;">
				<clist:filterTemplate />

				<div class="observations_list_wrapper" style="top: 0px;">
					<clist:showList />
				</div>
			</div>
		
		
	</div>
</body>
</html>