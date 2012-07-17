package speciespage

import java.util.Date;
import java.util.Map;

import grails.plugins.springsecurity.Secured;
import groovy.sql.Sql;

import org.springframework.security.access.prepost.PostFilter
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.acls.domain.BasePermission;
import org.springframework.security.acls.model.Permission;
import org.springframework.transaction.annotation.Transactional
import species.auth.SUser;
import species.groups.SpeciesGroup;
import species.groups.UserGroup;

class UserGroupService {
	
	static transactional = false
	
	def aclPermissionFactory
	def aclService
	def aclUtilService
	def springSecurityService
	def dataSource;

	void addPermission(UserGroup userGroup, SUser user, int permission) {
		addPermission userGroup, user, aclPermissionFactory.buildFromMask(permission)
	}

	//@PreAuthorize("hasPermission(#userGroup, admin) or hasRole('ROLE_RUN_AS_ACL_USERGROUP_FOUNDER')")
	@Transactional
	void addPermission(UserGroup userGroup, SUser user, Permission permission) {
		aclUtilService.addPermission userGroup, user.email, permission
	}

	@Transactional
	@PreAuthorize("hasRole('ROLE_USER')")
	UserGroup create(String name, String webaddress, String description, List founders, List members) {
		UserGroup userGroup = new UserGroup(name: name, webaddress: webaddress, description:description);
		userGroup.addToMembers(springSecurityService.currentUser);
		
		if(founders) {
			founders.each { it ->
				userGroup.addToMembers(it)
			}
		}
		
		if(members) {
			members.each { it ->
				userGroup.addToMembers(it);
			}
		}
		
		if(userGroup.save()) {
			// Grant the current principal administrative permission
			//aclService.createAcl objectIdentityRetrievalStrategy.getObjectIdentity(userGroup)
			addPermission userGroup, springSecurityService.currentUser, BasePermission.ADMINISTRATION
			founders.each {
				addPermission userGroup, it, BasePermission.ADMINISTRATION
				//TODO:send invitation requesting for confirmation
				//sendFounderInvitation(it);
			}
			
			members.each {
				addPermission userGroup, it, BasePermission.WRITE
				//TODO:send invitation requesting for confirmation
				//sendMemberInvitation(it);
			}
		}
		return userGroup
	}
	
	@Secured(['ROLE_USER', 'RUN_AS_ACL_USERGROUP_FOUNDER'])
	private void addMainFounder(UserGroup userGroup, SUser founder) {
		userGroup.addFounder(founder);
	}

	//@PreAuthorize("hasPermission(#id, 'species.groups.UserGroup', read) or hasPermission(#id, 'species.groups.UserGroup', admin)")
	UserGroup get(long id) {
		UserGroup.get id
	}
	
	@PreAuthorize("hasRole('ROLE_USER')")
	//@PostFilter("hasPermission(filterObject, read) or hasPermission(filterObject, admin)")
	List<UserGroup> list(Map params) {
		UserGroup.list params
	}
	
	int count() {
		UserGroup.count()
	}
	
	@Transactional
	@PreAuthorize("hasPermission(#userGroup, write) or hasPermission(#userGroup, admin)")
	void update(UserGroup userGroup, params) {
		userGroup.properties = params
	}
	
	@Transactional
	@PreAuthorize("hasPermission(#userGroup, delete) or hasPermission(#userGroup, admin)")
	void delete(UserGroup userGroup) {
		userGroup.delete()
		// Delete the ACL information as well
		aclUtilService.deleteAcl userGroup
	}
	
	@Transactional
	@PreAuthorize("hasPermission(#userGroup, admin)")
	void deletePermission(UserGroup userGroup, SUser user, Permission permission) {
		def acl = aclUtilService.readAcl(userGroup)
		// Remove all permissions associated with this particular recipient (string equality to KISS)
		acl.entries.eachWithIndex { entry, i ->
			if (entry.sid.equals(recipient) && entry.permission.equals(permission)) {
				acl.deleteAce i
			}
		}
		aclService.updateAcl acl
	}

	def getUserGroups(SUser userInstance) {
		return userInstance.groups;
	}
	
	/////////////// TAGS RELATED START /////////////////
	Map getAllRelatedUserGroupTags(params){
		//XXX should handle in generic way
		params.limit = 100
		params.offset = 0
		def uGroupIds = getRelatedUserGroups(params).relatedUserGroups.userGroups.userGroup.collect{it.id}
		uGroupIds.add(params.id.toLong())
		return getTagsFromUserGroups(uGroupIds)
	}
	
	Map getRelatedTagsFromUserGroup(UserGroup uGroup){
		int tagsLimit = 30;
		def tagNames = uGroup.tags
		LinkedHashMap tags = [:]
		if(tagNames.isEmpty()){
			return tags
		}
		
		def sql =  Sql.newInstance(dataSource);
		String query = "select t.name as name, count(t.name) as ug_count from tag_links as tl, tags as t, user_group ug where t.name in ('" +  tagNames.join("', '") + "') and ug.is_deleted = false and tl.tag_ref = ug.id and tl.type = 'userGroup' and t.id = tl.tag_id group by t.name order by count(t.name) desc, t.name asc limit " + tagsLimit;

		sql.rows(query).each{
			tags[it.getProperty("name")] = it.getProperty("ug_count");
		};
		return tags;
	}

	protected Map getTagsFromUserGroup(uGroupIds){
		int tagsLimit = 30;
		LinkedHashMap tags = [:]
		if(!uGroupIds){
			return tags
		}

		def sql =  Sql.newInstance(dataSource);
		String query = "select t.name as name, count(t.name) as ug_count from tag_links as tl, tags as t, user_group ug where tl.tag_ref in " + getIdList(uGroupIds)  + " and tl.tag_ref = ug.id  and tl.type = 'userGroup' and ug.is_deleted = false and t.id = tl.tag_id group by t.name order by count(t.name) desc, t.name asc limit " + tagsLimit;

		sql.rows(query).each{
			tags[it.getProperty("name")] = it.getProperty("ug_count");
		};
		return tags;
	}

	Map getFilteredTags(params){
		def userGroupInstanceList = getFilteredUserGroups(params, -1, -1, true).userGroupInstanceList
		println userGroupInstanceList;
		return getTagsFromUserGroup(userGroupInstanceList.collect{it.id});
	}
	
	/////////////// TAGS RELATED END /////////////////
	
	/**
	* Filter usergroups by group, habitat, tag, user, species
	* max: limit results to max: if max = -1 return all results
	* offset: offset results: if offset = -1 its not passed to the
	* executing query
	*/
   Map getFilteredUserGroups(params, max, offset, isMapView) {
	   //params.sGroup = (params.sGroup)? params.sGroup : SpeciesGroup.findByName(grailsApplication.config.speciesPortal.group.ALL).id
	   //params.habitat = (params.habitat)? params.habitat : Habitat.findByName(grailsApplication.config.speciesPortal.group.ALL).id
	   //params.habitat = params.habitat.toLong()
	   //params.userName = springSecurityService.currentUser.username;

	   def query = "select uGroup from UserGroup uGroup where uGroup.isDeleted = :isDeleted "
	   //def mapViewQuery = "select obv.id, obv.latitude, obv.longitude from Observation obv where obv.isDeleted = :isDeleted "
	   def queryParams = [isDeleted : false]
	   def filterQuery = ""
	   def activeFilters = [:]

//	   if(params.sGroup){
//		   params.sGroup = params.sGroup.toLong()
//		   def groupId = getSpeciesGroupIds(params.sGroup)
//		   if(!groupId){
//			   log.debug("No groups for id " + params.sGroup)
//		   }else{
//			   filterQuery += " and obv.group.id = :groupId "
//			   queryParams["groupId"] = groupId
//			   activeFilters["sGroup"] = groupId
//		   }
//	   }

	   if(params.tag){
		   query = "select uGroup from UserGroup uGroup,  TagLink tagLink where uGroup.isDeleted = :isDeleted "
		   //mapViewQuery = "select obv.id, obv.latitude, obv.longitude from Observation obv, TagLink tagLink where obv.isDeleted = :isDeleted "
		   filterQuery +=  " and uGroup.id = tagLink.tagRef and tagLink.type = :tagType and tagLink.tag.name = :tag "

		   queryParams["tag"] = params.tag
		   queryParams["tagType"] = 'userGroup';
		   activeFilters["tag"] = params.tag
	   }


//	   if(params.habitat && (params.habitat != Habitat.findByName(grailsApplication.config.speciesPortal.group.ALL).id)){
//		   filterQuery += " and obv.habitat.id = :habitat "
//		   queryParams["habitat"] = params.habitat
//		   activeFilters["habitat"] = params.habitat
//	   }
//
//	   if(params.user){
//		   filterQuery += " and obv.author.id = :user "
//		   queryParams["user"] = params.user.toLong()
//		   activeFilters["user"] = params.user.toLong()
//	   }
//
//	   if(params.speciesName && (params.speciesName != grailsApplication.config.speciesPortal.group.ALL)){
//		   filterQuery += " and obv.maxVotedSpeciesName = :speciesName "
//		   queryParams["speciesName"] = params.speciesName
//		   activeFilters["speciesName"] = params.speciesName
//	   }
//
//	   if(params.isFlagged && params.isFlagged.toBoolean()){
//		   filterQuery += " and obv.flagCount > 0 "
//	   }
//	   
//	   if(params.bounds){
//		   def bounds = params.bounds.split(",")
//
//		   def swLat = bounds[0]
//		   def swLon = bounds[1]
//		   def neLat = bounds[2]
//		   def neLon = bounds[3]
//
//		   filterQuery += " and obv.latitude > " + swLat + " and  obv.latitude < " + neLat + " and obv.longitude > " + swLon + " and obv.longitude < " + neLon
//		   activeFilters["bounds"] = params.bounds
//	   }

	   def orderByClause = " order by uGroup." + (params.sort ? params.sort : "foundedOn") +  " desc"
//
//	   if(isMapView) {
//		   query = mapViewQuery + filterQuery + orderByClause
//	   } else {
		   query += filterQuery + orderByClause
		   if(max != -1)
				queryParams["max"] = max
			if(offset != -1)
				queryParams["offset"] = offset
//	   }

		   log.debug "Getting filtered usergroups $query $queryParams";
	   def userGroupInstanceList = UserGroup.executeQuery(query, queryParams)
	   
	   return [userGroupInstanceList:userGroupInstanceList, queryParams:queryParams, activeFilters:activeFilters]
   }

   private Date parseDate(date){
	   try {
		   return date? Date.parse("dd/MM/yyyy", date):new Date();
	   } catch (Exception e) {
		   // TODO: handle exception
	   }
	   return null;
   }

   private String getIdList(l){
	   return l.toString().replace("[", "(").replace("]", ")")
   }
   
}