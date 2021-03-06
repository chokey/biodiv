<%@page import="content.Project"%>
<%@page import="content.eml.Document"%>

<table class="table table-hover tablesorter">
	<thead>
		<tr>
			<th title="${message(code: 'Dcoument.title.label', default: 'Title')}">${message(code: 'Dcoument.title.label', default: 'Title')}</th>
			<th title="${message(code: 'Dcoument.type.label', default: 'Document Type')}">${message(code: 'Dcoument.type.label', default: 'Document Type')}</th>
			<th title="${message(code: 'Dcoument.description.label', default: 'Description')}">${message(code: 'Dcoument.description.label', default: 'Description')}</th>
		</tr>
	</thead>

	<tbody class="mainContentList" name="p${params?.offset}">

		<g:each in="${documentInstanceList}" status="i" var="documentInstance">
			<tr class="mainContent ${(i % 2) == 0 ? 'odd' : 'even'}">
				<td>
					<a
						href='${uGroup.createLink(controller: "document", action:"show", id:documentInstance.id, 'userGroupWebaddress':params?.webaddress)}'>
						${documentInstance.title}
					</a>
				</td>
				<td>
					${documentInstance?.type?.value }
				</td>
				<td class="ellipsis multiline" style="max-width:300px;">
					${documentInstance.description}
				</td>
			</tr>
		</g:each>
	</tbody>
</table>
