<%@page import="species.utils.Utils"%>
<%@ page import="species.groups.UserGroup"%>
<%@ page import="species.Habitat"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="layout" content="main" />
<g:set var="entityName"
	value="${message(code: 'userGroup.label', default: 'Create New Group')}" />
<title>
	${entityName}
</title>
<r:require modules="userGroups_create" />
<style>
.btn-group.open .dropdown-menu {
	top: 43px;
}

.btn-large .caret {
	margin-top: 13px;
	position: absolute;
	right: 10px;
}

.btn-group .btn-large.dropdown-toggle {
	width: 300px;
	height: 44px;
	text-align: left;
	padding: 5px;
}

.textbox input {
	text-align: left;
	width: 290px;
	height: 34px;
	padding: 5px;
}

.form-horizontal .control-label {
	padding-top: 15px;
}

.btn-large {
	font-size: 13px;
}

.block {
	border-radius: 5px;
	background-color: #a6dfc8;
	margin: 3px;
}

.block label {
	float: left;
	text-align: left;
	padding: 10px;
	width: auto;
}

.block small {
	color: #444444;
}

.left-indent {
	margin-left: 100px;
}

.control-group.error  .help-inline {
	padding-top: 15px
}

.cke_skin_kama .cke_editor {
	display: table !important;
}

input.dms_field {
	width: 19%;
	display: none;
}

.userOrEmail-list {
	clear:none;
	width: 300px;
}
</style>


</head>
<body>
	<div class="container outer-wrapper">

		<div class="observation_create row">
			<div class="span12">
				<div class="page-header clearfix">
					<h1>
						${entityName}
					</h1>
				</div>
				<g:if test="${flash.message}">
					<div class="message">
						${flash.message}
					</div>
				</g:if>

				<g:hasErrors bean="${userGroupInstance}">
					<i class="icon-warning-sign"></i>
					<span class="label label-important"> <g:message
							code="fix.errors.before.proceeding" default="Fix errors" /> </span>
					<%--<g:renderErrors bean="${userGroupInstance}" as="list" />--%>
				</g:hasErrors>
			</div>
			<%
				def form_id = "createGroup"
				def form_action = createLink(action:'save')
				def form_button_name = "Create Group"
				def form_button_val = "Create Group"
				if(params.action == 'edit' || params.action == 'update'){
					//form_id = "updateGroup"
					form_action = createLink(action:'update', id:userGroupInstance.id)
				 	form_button_name = "Update Group"
					form_button_val = "Update Group"
				}
			
				%>
			<g:set var="founders_autofillUsersId" value="id1" />
			<g:set var="members_autofillUsersId" value="id2" />
			<form id="${form_id}" action="${form_action}" method="POST"
				class="form-horizontal">
				<div class="span12 super-section" style="clear: both;">
					<div class="span11 section"
						style="position: relative; overflow: visible;">
						<h3>What will this group be called?</h3>
						<div
							class="row control-group left-indent ${hasErrors(bean: userGroupInstance, field: 'name', 'error')}">

							<label for="name" class="control-label"><g:message
									code="userGroup.name.label" default="Group Name" /> </label>
							<div class="controls textbox">
								<div id="groups_div" class="btn-group" style="z-index: 3;">
									<g:textField name="name" value="${userGroupInstance?.name}" />

									<div class="help-inline">
										<g:hasErrors bean="${userGroupInstance}" field="name">
											<g:message code="userGroup.name.invalid" />
										</g:hasErrors>
									</div>
								</div>
							</div>
						</div>
						
												
						<div
							class="row control-group left-indent ${hasErrors(bean: userGroupInstance, field: 'description', 'error')}"
							>
							<!--label for="notes"><g:message code="observation.notes.label" default="Notes" /></label-->
							
								<label for="description" class="control-label">Description <small><g:message
											code="userGroup.description.message" default="" />
								</small>
								</label>
							<div class="controls  textbox">
								
								<ckeditor:config var="toolbar_editorToolbar">
										[
	    									[ 'Bold', 'Italic' ]
										]
										</ckeditor:config>
								<ckeditor:editor name="description" height="100px"
									toolbar="editorToolbar">
									${userGroupInstance?.description}
								</ckeditor:editor>
								<div class="help-inline">
									<g:hasErrors bean="${userGroupInstance}" field="description">
										<g:message code="userGroup.description.invalid" />
									</g:hasErrors>
								</div>
							</div>

						</div>
						
						<!-- div
							class="row control-group left-indent ${hasErrors(bean: userGroupInstance, field: 'webaddress', 'error')}">
							<label for="webaddress" class="control-label"><g:message
									code="userGroup.webaddress.label" default="Web Address" /> </label>
							<div class="controls  textbox">
								<div id="groups_div" class="btn-group" style="z-index: 3;">
									<span class="whiteboard"> <g:createLink action='show'
											base="${Utils.getDomainServerUrl(request)}"></g:createLink>/</span>
									<g:textField name="webaddress"
										value="${userGroupInstance?.webaddress}" />

									<div class="help-inline">
										<g:hasErrors bean="${userGroupInstance}" field="webaddress">
											<g:message code="userGroup.webaddress.invalid" />
										</g:hasErrors>
									</div>
								</div>
							</div>
						</div-->

						<div
							class="row control-group left-indent ${hasErrors(bean: userGroupInstance, field: 'webaddress', 'error')}">
							<label for="icon" class="control-label"><g:message
									code="userGroup.icon.label" default="Icon" /> </label>
							<div class="controls">
								<div id="groups_div" class="btn-group" style="z-index: 3;">


									<div>
										<i class="icon-picture"></i><span>Upload group icon preferably of dimensions 150px X 50px and size < 50KB</span>
										<div
											class="resources control-group ${hasErrors(bean: userGroupInstance, field: 'icon', 'error')}">

											<%def thumbnail = userGroupInstance.icon%>
											<div class='span3' style="height:80px; width:auto;margin-left: 0px;">
												<img id="thumbnail"
													src='${createLink(url: userGroupInstance.mainImage().fileName)}' class='logo'/>
												<a id="change_picture" onclick="$('#attachFile').select()[0].click();return false;"> Change Picture</a>
											</div>
											<input id="icon" name="icon" type="hidden" value='${thumbnail}' />
											<div id="image-resources-msg" class="help-inline">
												<g:renderErrors bean="${userGroupInstance}" as="list"
													field="icon" />
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>

					</div>
				</div>

				<div class="span12 super-section" style="clear: both;">
					<div class="span11 section"
						style="position: relative; overflow: visible;">
						<h3>Driven By</h3>
						<div
							class="row control-group left-indent ${hasErrors(bean: userGroupInstance, field: 'founders', 'error')}">
							<label for="founders" class="control-label"><g:message
									code="userGroup.founders.label" default="Invite Founders" /> </label>
							<div class="controls  textbox">
								<sUser:selectUsers model="['id':founders_autofillUsersId]" />
								<input type="hidden" name="founderUserIds" id="founderUserIds" />
								
							</div>
						</div>

						<!-- div
							class="row control-group left-indent ${hasErrors(bean: userGroupInstance, field: 'members', 'error')}">
							<label for="members" class="control-label"><g:message
									code="userGroup.members.label" default="Invite Members" /> </label>
							<div class="controls  textbox">
								<div class="create_tags section-item">
									<sUser:selectUsers model="['id':members_autofillUsersId]"/>
									<input type="hidden" name="memberUserIds" id="memberUserIds" />
								</div>
							</div>
						</div-->
					</div>
				</div>

				<!-- div class="span12 super-section" style="clear: both;">
					<div class="section" style="position: relative; overflow: visible;">
						<h3>Additional Information</h3>
						
						
					</div>
				</div-->

				<div class="span12 super-section" style="clear: both;">
					<div class="section"
						style="position: relative; overflow: visible;">
						<h3>Interested In</h3>
						
						<div class="row control-group left-indent">
							
								<label class="control-label">Species Groups & Habitats
								</label>
							
							<div class="filters controls textbox" style="position: relative;">
								<obv:showGroupFilter
									model="['observationInstance':observationInstance]" />
							</div>
						</div>
						
						<div class="row control-group left-indent">
							
								<label class="control-label">Tags <small><g:message
											code="observation.tags.message" default="" />
								</small>
								</label>
							
							<div class="create_tags controls  textbox" >
								<ul id="tags">
									<g:each in="${userGroupInstance.tags}" var="tag">
										<li>${tag}</li>
									</g:each>
								</ul>
							</div>
						</div>
						
					</div>
				</div>

				<div class="span12 super-section" style="clear: both;">
					<div class="span11 section"
						style="position: relative; overflow: visible;">
						<h3>Permissions</h3>
						<div class="row control-group left-indent">
							
								<label class="checkbox" style="text-align: left;"> 
								 <g:checkBox style="margin-left:0px;"
												name="allowUsersToJoin" checked="${userGroupInstance.allowUsersToJoin}"/>
								 <g:message code="userGroup.permissions.members.joining" default="Can users join with out invitation? (If no, registered users will be able to request for invitation from group's home page)" /> </label>
						</div>
						<div class="row control-group left-indent">
							
								<label class="checkbox" style="text-align: left;"> 
								 <g:checkBox style="margin-left:0px;"
												name="allowObvCrossPosting" checked="${userGroupInstance.allowObvCrossPosting}"/>
								 <g:message code="userGroup.permissions.observations.crossposting" default="Allow Observations Cross Posting" /> </label>
						</div>
						<div class="row control-group left-indent">
							
								<label class="checkbox" style="text-align: left;"> 
								 <g:checkBox style="margin-left:0px;"
												name="allowMembersToMakeSpeciesCall" checked="${userGroupInstance.allowMembersToMakeSpeciesCall}"/>
								 <g:message code="userGroup.permissions.observations.allowMembersToMakeSpeciesCall" default="Allow members to make species calls and agree upon existing species calls" /> </label>
						</div>
						<div class="row control-group left-indent">
							
								<label class="checkbox" style="text-align: left;"> 
								 <g:checkBox style="margin-left:0px;"
												name="allowNonMembersToComment" checked="${userGroupInstance.allowNonMembersToComment}"/>
								 <g:message code="userGroup.permissions.comments.bynonmembers" default="Allow non members to comment???" /> </label>
						</div>
					</div>
				</div>

				<div class="span12" style="margin-top: 20px; margin-bottom: 40px;">
					<g:if test="${userGroupInstance?.id}">
						<div class="btn btn-danger"
							style="float: right; margin-right: 5px;">
							<a
								href="${createLink(action:'deleted', id:userGroupInstance.id)}"
								onclick="return confirm('${message(code: 'default.userGroup.delete.confirm.message', default: 'This group and its content will be deleted. Are you sure ?')}');">Delete
								Group </a>
						</div>
					</g:if>
					<span class="policy-text"> By submitting this form for
						creating a new group you agree to our <a href="/terms">Terms
							and Conditions</a> on the use of our site </span> <a id="createGroupSubmit"
						class="btn btn-primary" style="float: right; margin-right: 5px;">
						${form_button_val} </a>
				</div>


			</form>
			<form id="upload_resource" enctype="multipart/form-data"
				title="Add a logo for this group" method="post"
				class="${hasErrors(bean: userGroupInstance, field: 'icon', 'errors')}">

				<input type="file" id="attachFile" name="resources" accept="image/*"/> 
				<span class="msg" style="float: right"></span> 
				<input type="hidden" name='dir' value="${userGroupDir}" />
			</form>
			
		</div>
	</div>

	<r:script>
$(document).ready(function() {

    	//hack: for fixing ie image upload
        if (navigator.appName.indexOf('Microsoft') != -1) {
            $('#upload_resource').css({'visibility':'visible'});
            //$('#change_picture').hide();
        } else {
            $('#upload_resource').css({'visibility':'hidden'});
            //$('#change_picture').show();
        }
		
		$('#attachFile').change(function(e){
  			$('#upload_resource').submit().find("span.msg").html("Uploading... Please wait...");
		});

     	$('#upload_resource').ajaxForm({ 
			url:'${createLink(action:'upload_resource')}',
			dataType: 'xml',//could not parse json wih this form plugin 
			clearForm: true,
			resetForm: true,
			type: 'POST',
			 
			beforeSubmit: function(formData, jqForm, options) {
				return true;
			}, 
            xhr: function() {  // custom xhr
                myXhr = $.ajaxSettings.xhr();
                return myXhr;
            },
			success: function(responseXML, statusText, xhr, form) {
				$(form).find("span.msg").html("");
				var rootDir = '${grailsApplication.config.speciesPortal.userGroups.serverURL}'
				var dir = $(responseXML).find('dir').text();
				var dirInput = $('#upload_resource input[name="dir"]');
				if(!dirInput.val()){
					$(dirInput).val(dir);
				}
				
				$(responseXML).find('resources').find('image').each(function() {
					var file = dir + "/" + $(this).attr('fileName');
					var thumbnail = rootDir + file.replace(/\.[a-zA-Z]{3,4}$/, "${grailsApplication.config.speciesPortal.resources.images.thumbnail.suffix}");
					$("#icon").val(file);
					$("#thumbnail").attr("src", thumbnail);
				});
				$("#image-resources-msg").parent(".resources").removeClass("error");
                $("#image-resources-msg").html("");
			}, error:function (xhr, ajaxOptions, thrownError){
					//successHandler is used when ajax login succedes
	            	var successHandler = this.success, errorHandler;
	            	handleError(xhr, ajaxOptions, thrownError, successHandler, function() {
						var response = $.parseJSON(xhr.responseText);
						if(response.error){
							$("#image-resources-msg").parent(".resources").addClass("error");
							$("#image-resources-msg").html(response.error);
						}
						
						var messageNode = $(".message .resources");
						if(messageNode.length == 0 ) {
							$("#upload_resource").prepend('<div class="message">'+(response?response.error:"Error")+'</div>');
						} else {
							messageNode.append(response?response.error:"Error");
						}
					});
           } 
     	});  
     	
     	
	var founders_autofillUsersComp = $("#userAndEmailList_${founders_autofillUsersId}").autofillUsers({
		usersUrl : '${createLink(controller:'SUser', action: 'terms')}'
	});
	
	<g:if test="${userGroupInstance.isAttached() }">
			<g:each in="${userGroupInstance.getFounders(userGroupInstance.getFoundersCount()+1, 0)}" var="user">
		founders_autofillUsersComp[0].addUserId({'item':{'userId':'${user.id}', 'value':'${user.name}'}});
	</g:each>
		</g:if>

		<%--	var members_autofillUsersComp = $("#userAndEmailList_${members_autofillUsersId}").autofillUsers({--%>
<%--		usersUrl : '${createLink(controller:'SUser', action: 'terms')}'--%>
<%--	});--%>
		<%--	--%>
		<%--	<g:each in="${userGroupInstance?.getMembers()}" var="user">--%>
		<%--		members_autofillUsersComp[0].addUserId('item':{{'userId':'${user.id}', 'value':'${user.name}'}});--%>
		<%--	</g:each>--%>
		<%--	--%>
		
	function getSelectedGroup() {
	    var grp = []; 
	    $('#speciesGroupFilter button').each (function() {
	            if($(this).hasClass('active')) {
	                    grp.push($(this).attr('value'));
	            }
	    });
	    return grp;	
	} 
	    
	function getSelectedHabitat() {
	    var hbt = []; 
	    $('#habitatFilter button').each (function() {
	            if($(this).hasClass('active')) {
	                    hbt.push($(this).attr('value'));
	            }
	    });
	    return hbt;	
	}
	 
	 $("#createGroupSubmit").click(function(){
		$('#founderUserIds').val(founders_autofillUsersComp[0].getEmailAndIdsList().join(","));
		//$('#memberUserIds').val(members_autofillUsersComp[0].getEmailAndIdsList().join(","));
		var tags = $("#tags").tagit("tags");
       	$.each(tags, function(index){
       		var input = $("<input>").attr("type", "hidden").attr("name", "tags."+index).val(this.label);
			$('#${form_id}').append($(input));	
       	})
        
        var speciesGroups = getSelectedGroup();
        var habitats = getSelectedHabitat();
        
       	$.each(speciesGroups, function(index){
       		var input = $("<input>").attr("type", "hidden").attr("name", "speciesGroup."+index).val(this);
			$('#${form_id}').append($(input));	
       	})
        
       	$.each(habitats, function(index){
       		var input = $("<input>").attr("type", "hidden").attr("name", "habitat."+index).val(this);
			$('#${form_id}').append($(input));	
       	})
       	
        $("#${form_id}").submit();
        return false;
        
	});
	
	$("#tags .tagit-input").watermark("Add some tags");	
	$("#tags").tagit({select:true,  tagSource: "${g.createLink(action: 'tags')}", triggerKeys:['enter', 'comma', 'tab'], maxLength:30});
	$(".tagit-hiddenSelect").css('display','none');
	
	$('#speciesGroupFilter button').attr('data-toggle', 'buttons-checkbox').click(function(){
    	if($(this).hasClass('active')) {
    		$(this).removeClass('active');
    	} else {
    		$(this).addClass('active');
    	}
    	return false;
 	});
	
        
 	$('#habitatFilter button').attr('data-toggle', 'buttons-checkbox').click(function(){
    	if($(this).hasClass('active')) {
    		$(this).removeClass('active');
    	} else {
    		$(this).addClass('active');
    	}
    	return false;
 	});
 	
 	<%
 		userGroupInstance.speciesGroups.each {
			out << "jQuery('#group_${it.id}').addClass('active');";
		}
		userGroupInstance.habitats.each {
			out << "jQuery('#habitat_${it.id}').addClass('active');";
		}
	%>
 	
});
</r:script>

</body>

</html>