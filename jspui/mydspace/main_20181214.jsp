<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Main My DSpace page
  -
  -
  - Attributes:
  -    mydspace.user:    current user (EPerson)
  -    workspace.items:  WorkspaceItem[] array for this user
  -    workflow.items:   WorkflowItem[] array of submissions from this user in
  -                      workflow system
  -    workflow.owned:   WorkflowItem[] array of tasks owned
  -    workflow.pooled   WorkflowItem[] array of pooled tasks
  --%>

<%@page import="java.net.URLEncoder"%>
<%@page import="edu.calis.ir.pku.util.PKUUtils"%>
<%@page import="org.dspace.core.ConfigurationManager"%>
<%@page import="org.dspace.app.webui.util.UIUtil"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page  import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.regex.*" %>

<%@ page import="org.dspace.app.webui.servlet.MyDSpaceServlet" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community"%>
<%@ page import="org.dspace.content.DCDate" %>
<%@ page import="org.dspace.content.Metadatum" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.dspace.content.SupervisedItem" %>
<%@ page import="org.dspace.content.WorkspaceItem" %>
<%@ page import="org.dspace.core.Utils" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.eperson.Group" %>
<%@ page import="org.dspace.workflow.WorkflowItem" %>
<%@ page import="org.dspace.workflow.WorkflowManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.dspace.app.itemimport.BatchUpload"%>
<%@ page import="edu.calis.ir.pku.components.Researcher" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%> 
<%@page import="org.springframework.context.ApplicationContext" %> 
<%@page import="org.pprun.common.security.ThrottleFilter"%>

<%
    EPerson user = (EPerson) request.getAttribute("mydspace.user");

    WorkspaceItem[] workspaceItems =
        (WorkspaceItem[]) request.getAttribute("workspace.items");

    WorkflowItem[] workflowItems =
        (WorkflowItem[]) request.getAttribute("workflow.items");

    WorkflowItem[] owned =
        (WorkflowItem[]) request.getAttribute("workflow.owned");

    WorkflowItem[] pooled =
        (WorkflowItem[]) request.getAttribute("workflow.pooled");
	
    Group [] groupMemberships =
        (Group []) request.getAttribute("group.memberships");

    SupervisedItem[] supervisedItems =
        (SupervisedItem[]) request.getAttribute("supervised.items");
    
    List<String> exportsAvailable = (List<String>)request.getAttribute("export.archives");
    
    List<BatchUpload> importsAvailable = (List<BatchUpload>)request.getAttribute("import.uploads");
    
    // Is the logged in user an admin
    Boolean displayMembership = (Boolean)request.getAttribute("display.groupmemberships");
    boolean displayGroupMembership = (displayMembership == null ? false : displayMembership.booleanValue());
    
    Researcher researcher = Researcher.findByUid(UIUtil.obtainContext(request), user.getNetid());
    String userType = (String) request.getSession().getAttribute("researcher.user.type");
    boolean isNeed2CreateResearcher = false;
    if(StringUtils.isNotEmpty(userType) && ConfigurationManager.getProperty("webui.researcher.user.type").contains(userType) && researcher == null) {
    	isNeed2CreateResearcher = true;	
    }
%>

<script type="text/javascript" src="<%=request.getContextPath()%>/calis/js/community-list.js"></script>

<dspace:layout locbar="off" style="submission" titlekey="jsp.mydspace" nocache="true">

	<div class="panel panel-primary">
        <div class="panel-heading">
                    <fmt:message key="jsp.mydspace"/>: <%= Utils.addEntities(user.getFullName()) %>
	                <span class="pull-right"><dspace:popup page="<%= LocaleSupport.getLocalizedMessage(pageContext, \"help.index\") + \"#mydspace\"%>"><fmt:message key="jsp.help"/></dspace:popup></span>
        </div>         
<%
boolean hasCollection = (Boolean)request.getAttribute("has_collection");
boolean hasEmail = (Boolean)request.getAttribute("has_email");
//Is the logged in user an admin
Boolean admin = (Boolean)request.getAttribute("is.admin");
boolean isAdmin = (admin == null ? false : admin.booleanValue());
if((hasCollection && hasEmail) || isAdmin){
%>
		<div class="panel-body">
		    <form action="<%= request.getContextPath() %>/mydspace" method="post">
		        <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                <%
                //以下为管理员，是管理员的才可以操作"提交新的作品"的按钮
                //if (user.getEmail() != null) {
                    String navbarEmail = user.getEmail();//登录用户名 
                    if(navbarEmail.equals("1605000@wsyu.edu.cn") || navbarEmail.equals("1105002@wsyu.edu.cn") || navbarEmail.equals("0605001@wsyu.edu.cn") || navbarEmail.equals("1711004@wsyu.edu.cn") || navbarEmail.equals("1712002@wsyu.edu.cn") || navbarEmail.equals("1811002@wsyu.edu.cn") || navbarEmail.equals("1811001@wsyu.edu.cn") {
                        //out.print(navbarEmail);
                        %>
                        <input class="btn btn-success" type="submit" name="submit_new" value="<fmt:message key="jsp.mydspace.main.start.button"/>" />
                <%
                    } else {
                //} 
                    %>
                        <input class="btn btn-success" type="button"  value="<fmt:message key="jsp.mydspace.main.start.button"/>" onclick="alert('暂未开通此权限！')"/>
                <%
                    }
                %>
                <input class="btn btn-info" type="submit" name="submit_own" value="<fmt:message key="jsp.mydspace.main.view.button"/>" />
                
                <%
				if(isNeed2CreateResearcher) {
				%>
                <!-- 查看我的学术成果 -->
				<a class="btn btn-success" href="<%=request.getContextPath() %>/researcher?action=preadd"><fmt:message key="jsp.mydspace.main.researcher.view" /></a>
				
				<%
					} else {
						Researcher r = Researcher.findByUid(UIUtil.obtainContext(request), user.getNetid());
						if(r != null) {
							String uid = r.getUid();
							String fullname = r.getName();
							try {
								uid = PKUUtils.encrypt(uid, "PkuLibIR"); 
								fullname = URLEncoder.encode(fullname, "utf-8");
							} catch (java.lang.Exception e) {
								e.printStackTrace();
							}
				%>
                <!-- 查看我的学术成果 -->
				<a class="btn btn-success" href="<%=request.getContextPath() %>/researcher?id=<%=r.getID() %>&uid=<%=uid %>&fullname=<%=fullname %>"><fmt:message key="jsp.mydspace.main.researcher.view" /></a> 
				<%
						}
					}
				%>
		    </form>
			
<%-- Task list:  Only display if the user has any tasks --%>
<%
    if (owned.length > 0)
    {
%>
    <h3><fmt:message key="jsp.mydspace.main.heading2"/></h3>

    <p class="submitFormHelp">
        <%-- Below are the current tasks that you have chosen to do. --%>
        <fmt:message key="jsp.mydspace.main.text1"/>
    </p>

    <table class="table" align="center" summary="Table listing owned tasks">
        <tr>
            <th id="t1" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.task"/></th>
            <th id="t2" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.item"/></th>
            <th id="t3" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.subto"/></th>
            <th id="t4" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.subby"/></th>
            <th id="t5" class="oddRowEvenCol">&nbsp;</th>
        </tr>
<%
        // even or odd row:  Starts even since header row is odd (1).  Toggled
        // between "odd" and "even" so alternate rows are light and dark, for
        // easier reading.
        String row = "even";

        for (int i = 0; i < owned.length; i++)
        {
            Metadatum[] titleArray =
                owned[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                                                  : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            EPerson submitter = owned[i].getItem().getSubmitter();
%>
        <tr>
                <td headers="t1" class="<%= row %>RowOddCol">
<%
            switch (owned[i].getState())
            {

            //There was once some code...
            case WorkflowManager.WFSTATE_STEP1: %><fmt:message key="jsp.mydspace.main.sub1"/><% break;
            case WorkflowManager.WFSTATE_STEP2: %><fmt:message key="jsp.mydspace.main.sub2"/><% break;
            case WorkflowManager.WFSTATE_STEP3: %><fmt:message key="jsp.mydspace.main.sub3"/><% break;
            }
%>
                </td>
                <td headers="t2" class="<%= row %>RowEvenCol"><%= Utils.addEntities(title) %></td>
                <td headers="t3" class="<%= row %>RowOddCol"><%= owned[i].getCollection().getMetadata("name") %></td>
                <td headers="t4" class="<%= row %>RowEvenCol"><a href="mailto:<%= submitter.getEmail() %>"><%= Utils.addEntities(submitter.getFullName()) %></a></td>
                <!-- <td headers="t5" class="<%= row %>RowOddCol"></td> -->
                <td headers="t5" class="<%= row %>RowEvenCol">
                     <form action="<%= request.getContextPath() %>/mydspace" method="post">
                        <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                        <input type="hidden" name="workflow_id" value="<%= owned[i].getID() %>" />  
                        <input class="btn btn-primary" type="submit" name="submit_perform" value="<fmt:message key="jsp.mydspace.main.perform.button"/>" />  
                        <input class="btn btn-default" type="submit" name="submit_return" value="<fmt:message key="jsp.mydspace.main.return.button"/>" />
                     </form> 
                </td>
        </tr>
<%
            row = (row.equals("even") ? "odd" : "even" );
        }
%>
    </table>
<%
    }

    // Pooled tasks - only show if there are any
    if (pooled.length > 0)
    {
%>
    <h3><fmt:message key="jsp.mydspace.main.heading3"/></h3>

    <p class="submitFormHelp">
        <%--Below are tasks in the task pool that have been assigned to you. --%>
        <fmt:message key="jsp.mydspace.main.text2"/>
    </p>

    <table class="table" align="center" summary="Table listing the tasks in the pool">
        <tr>
            <th id="t6" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.task"/></th>
            <th id="t7" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.item"/></th>
            <th id="t8" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.subto"/></th>
            <th id="t9" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.subby"/></th>
            <th class="oddRowOddCol"> </th>
        </tr>
<%
        // even or odd row:  Starts even since header row is odd (1).  Toggled
        // between "odd" and "even" so alternate rows are light and dark, for
        // easier reading.
        String row = "even";

        for (int i = 0; i < pooled.length; i++)
        {
            Metadatum[] titleArray =
                pooled[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                    : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            EPerson submitter = pooled[i].getItem().getSubmitter();
%>
        <tr>
                    <td headers="t6" class="<%= row %>RowOddCol">
<%
            switch (pooled[i].getState())
            {
            case WorkflowManager.WFSTATE_STEP1POOL: %><fmt:message key="jsp.mydspace.main.sub1"/><% break;
            case WorkflowManager.WFSTATE_STEP2POOL: %><fmt:message key="jsp.mydspace.main.sub2"/><% break;
            case WorkflowManager.WFSTATE_STEP3POOL: %><fmt:message key="jsp.mydspace.main.sub3"/><% break;
            }
%>
                    </td>
                    <td headers="t7" class="<%= row %>RowEvenCol"><%= Utils.addEntities(title) %></td>
                    <td headers="t8" class="<%= row %>RowOddCol"><%= pooled[i].getCollection().getMetadata("name") %></td>
                    <td headers="t9" class="<%= row %>RowEvenCol"><a href="mailto:<%= submitter.getEmail() %>"><%= Utils.addEntities(submitter.getFullName()) %></a></td>
                    <td class="<%= row %>RowOddCol">
                        <form action="<%= request.getContextPath() %>/mydspace" method="post">
                            <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                            <input type="hidden" name="workflow_id" value="<%= pooled[i].getID() %>" />
                            <input class="btn btn-default" type="submit" name="submit_claim" value="<fmt:message key="jsp.mydspace.main.take.button"/>" />
                        </form> 
                    </td>
        </tr>
<%
            row = (row.equals("even") ? "odd" : "even");
        }
%>
    </table>
<%
    }

    // Display workspace items (authoring or supervised), if any
    if (workspaceItems.length > 0 || supervisedItems.length > 0)
    {
        // even or odd row:  Starts even since header row is odd (1)
        String row = "even";
%>

    <h3><fmt:message key="jsp.mydspace.main.heading4"/></h3>

    <p><fmt:message key="jsp.mydspace.main.text4" /></p>

    <table class="table" align="center" summary="Table listing unfinished submissions">
        <tr>
            <th class="oddRowOddCol">&nbsp;</th>
            <th id="t10" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.subby"/></th>
            <th id="t11" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.elem1"/></th>
            <th id="t12" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.elem2"/></th>
            <th id="t13" class="oddRowOddCol">&nbsp;</th>
        </tr>
<%
        if (supervisedItems.length > 0 && workspaceItems.length > 0)
        {
%>
        <tr>
            <th colspan="5">
                <%-- Authoring --%>
                <fmt:message key="jsp.mydspace.main.authoring" />
            </th>
        </tr>
<%
        }

        for (int i = 0; i < workspaceItems.length; i++)
        {
            Metadatum[] titleArray =
                workspaceItems[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                    : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            EPerson submitter = workspaceItems[i].getItem().getSubmitter();
%>
        <tr>
            <td class="<%= row %>RowOddCol">
                <form action="<%= request.getContextPath() %>/workspace" method="post">
                    <input type="hidden" name="workspace_id" value="<%= workspaceItems[i].getID() %>"/>
                    <input class="btn btn-default" type="submit" name="submit_open" value="<fmt:message key="jsp.mydspace.general.open" />"/>
                </form>
            </td>
            <td headers="t10" class="<%= row %>RowEvenCol">
                <a href="mailto:<%= submitter.getEmail() %>"><%= Utils.addEntities(submitter.getFullName()) %></a>
            </td>
            <td headers="t11" class="<%= row %>RowOddCol"><%= Utils.addEntities(title) %></td>
            <td headers="t12" class="<%= row %>RowEvenCol"><%= workspaceItems[i].getCollection().getMetadata("name") %></td>
            <td headers="t13" class="<%= row %>RowOddCol">
                <form action="<%= request.getContextPath() %>/mydspace" method="post">
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>"/>
                    <input type="hidden" name="workspace_id" value="<%= workspaceItems[i].getID() %>"/>
                    <input class="btn btn-danger" type="submit" name="submit_delete" value="<fmt:message key="jsp.mydspace.general.remove" />"/>
                </form> 
            </td>
        </tr>
<%
            row = (row.equals("even") ? "odd" : "even" );
        }
%>

<%-- Start of the Supervisors workspace list --%>
<%
        if (supervisedItems.length > 0)
        {
%>
        <tr>
            <th colspan="5">
                <fmt:message key="jsp.mydspace.main.supervising" />
            </th>
        </tr>
<%
        }

        for (int i = 0; i < supervisedItems.length; i++)
        {
            Metadatum[] titleArray =
                supervisedItems[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                    : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
            EPerson submitter = supervisedItems[i].getItem().getSubmitter();
%>

        <tr>
            <td class="<%= row %>RowOddCol">
                <form action="<%= request.getContextPath() %>/workspace" method="post">
                    <input type="hidden" name="workspace_id" value="<%= supervisedItems[i].getID() %>"/>
                    <input class="btn btn-default" type="submit" name="submit_open" value="<fmt:message key="jsp.mydspace.general.open" />"/>
                </form>
            </td>
            <td class="<%= row %>RowEvenCol">
                <a href="mailto:<%= submitter.getEmail() %>"><%= Utils.addEntities(submitter.getFullName()) %></a>
            </td>
            <td class="<%= row %>RowOddCol"><%= Utils.addEntities(title) %></td>
            <td class="<%= row %>RowEvenCol"><%= supervisedItems[i].getCollection().getMetadata("name") %></td>
            <td class="<%= row %>RowOddCol">
                <form action="<%= request.getContextPath() %>/mydspace" method="post">
                    <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>"/>
                    <input type="hidden" name="workspace_id" value="<%= supervisedItems[i].getID() %>"/>
                    <input class="btn btn-default" type="submit" name="submit_delete" value="<fmt:message key="jsp.mydspace.general.remove" />"/>
                </form>  
            </td>
        </tr>
<%
            row = (row.equals("even") ? "odd" : "even" );
        }
%>
    </table>
<%
    }
%>

<%
    // Display workflow items, if any
    if (workflowItems.length > 0)
    {
        // even or odd row:  Starts even since header row is odd (1)
        String row = "even";
%>
    <h3><fmt:message key="jsp.mydspace.main.heading5"/></h3>

    <table class="table" align="center" summary="Table listing submissions in workflow process">
        <tr>
            <th id="t14" class="oddRowOddCol"><fmt:message key="jsp.mydspace.main.elem1"/></th>
            <th id="t15" class="oddRowEvenCol"><fmt:message key="jsp.mydspace.main.elem2"/></th>
        </tr>
<%
        for (int i = 0; i < workflowItems.length; i++)
        {
            Metadatum[] titleArray =
                workflowItems[i].getItem().getDC("title", null, Item.ANY);
            String title = (titleArray.length > 0 ? titleArray[0].value
                    : LocaleSupport.getLocalizedMessage(pageContext,"jsp.general.untitled") );
%>
            <tr>
                <td headers="t14" class="<%= row %>RowOddCol"><%= Utils.addEntities(title) %></td>
                <td headers="t15" class="<%= row %>RowEvenCol">
                   <form action="<%= request.getContextPath() %>/mydspace" method="post">
                       <%= workflowItems[i].getCollection().getMetadata("name") %>
                       <input type="hidden" name="step" value="<%= MyDSpaceServlet.MAIN_PAGE %>" />
                       <input type="hidden" name="workflow_id" value="<%= workflowItems[i].getID() %>" />
                   </form>   
                </td>
            </tr>
<%
      row = (row.equals("even") ? "odd" : "even" );
    }
%>
    </table>
<%
  }

  if(displayGroupMembership && groupMemberships.length>0)
  {
%>
    <h3><fmt:message key="jsp.mydspace.main.heading6"/></h3>
    <ul>
<%
    for(int i=0; i<groupMemberships.length; i++)
    {
%>
    <li><%=groupMemberships[i].getName()%></li> 
<%    
    }
%>
	</ul>
<%
  }
%>

	<%if(exportsAvailable!=null && exportsAvailable.size()>0){ %>
	<h3><fmt:message key="jsp.mydspace.main.heading7"/></h3>
	<ol class="exportArchives">
		<%for(String fileName:exportsAvailable){%>
			<li><a href="<%=request.getContextPath()+"/exportdownload/"+fileName%>" title="<fmt:message key="jsp.mydspace.main.export.archive.title"><fmt:param><%= fileName %></fmt:param></fmt:message>"><%=fileName%></a></li> 
		<% } %>
	</ol>
	<%} %>
	
	<%if(importsAvailable!=null && importsAvailable.size()>0){ %>
	<h3><fmt:message key="jsp.mydspace.main.heading8"/></h3>
	<ul class="exportArchives" style="list-style-type: none;">
		<% int i=0;
			for(BatchUpload batchUpload : importsAvailable){
		%>
			<li style="padding-top:5px; margin-top:10px">
				<div style="float:left"><b><%= batchUpload.getDateFormatted() %></b></div>
				<% if (batchUpload.isSuccessful()){ %>
					<div style= "float:left">&nbsp;&nbsp;--> <span style="color:green"><fmt:message key="jsp.dspace-admin.batchimport.success"/></span></div>
				<% } else { %>
					<div style= "float:left;">&nbsp;&nbsp;--> <span style="color:red"><fmt:message key="jsp.dspace-admin.batchimport.failure"/></span></div>
				<% } %>
				<div style="float:left; padding-left:20px">
					<a id="a2_<%= i%>" style="display:none; font-size:12px" href="javascript:showMoreClicked(<%= i%>);"><i>(<fmt:message key="jsp.dspace-admin.batchimport.hide"/>)</i></a>
					<a id="a1_<%= i%>" style="font-size:12px" href="javascript:showMoreClicked(<%= i%>);"><i>(<fmt:message key="jsp.dspace-admin.batchimport.show"/>)</i></a>
				</div><br/>
				<div id="moreinfo_<%= i%>" style="clear:both; display:none; margin-top:15px; padding:10px; border:1px solid; border-radius:4px; border-color:#bbb">
					<div><fmt:message key="jsp.dspace-admin.batchimport.itemstobeimported"/>: <b><%= batchUpload.getTotalItems() %></b></div>
					<div style="float:left"><fmt:message key="jsp.dspace-admin.batchimport.itemsimported"/>: <b><%= batchUpload.getItemsImported() %></b></div>
					<div style="float:left; padding-left:20px">
					<a id="a4_<%= i%>" style="display:none; font-size:12px" href="javascript:showItemsClicked(<%= i%>);"><i>(<fmt:message key="jsp.dspace-admin.batchimport.hideitems"/>)</i></a>
					<a id="a3_<%= i%>" style="font-size:12px" href="javascript:showItemsClicked(<%= i%>);"><i>(<fmt:message key="jsp.dspace-admin.batchimport.showitems"/>)</i></a>
				</div>
				<br/>
					<div id="iteminfo_<%= i%>" style="clear:both; display:none; border:1px solid; background-color:#eeeeee; margin:30px 20px">
						<%
							for(String handle : batchUpload.getHandlesImported()){
						%>
							<div style="padding-left:10px"><a href="<%= request.getContextPath() %>/handle/<%= handle %>"><%= handle %></a></div>
						<%
							}
						%>
					</div>
					<div style="margin-top:10px">
						<form action="<%= request.getContextPath() %>/mydspace" method="post">
							<input type="hidden" name="step" value="7">
							<input type="hidden" name="uploadid" value="<%= batchUpload.getDir().getName() %>">
							<input class="btn btn-info" type="submit" name="submit_mapfile" value="<fmt:message key="jsp.dspace-admin.batchimport.downloadmapfile"/>">
							<% if (!batchUpload.isSuccessful()){ %>
								<input class="btn btn-warning" type="submit" name="submit_resume" value="<fmt:message key="jsp.dspace-admin.batchimport.resume"/>">
							<% } %>
							<input class="btn btn-danger" type="submit" name="submit_delete" value="<fmt:message key="jsp.dspace-admin.batchimport.deleteitems"/>">
						</form>
					<div>
					<% if (!batchUpload.getErrorMsgHTML().equals("")){ %>
						<div style="margin-top:20px; padding-left:20px; background-color:#eee">
							<div style="padding-top:10px; font-weight:bold">
								<fmt:message key="jsp.dspace-admin.batchimport.errormsg"/>
							</div>
							<div style="padding-top:20px">
								<%= batchUpload.getErrorMsgHTML() %>
							</div>
						</div>
					<% } %>
				</div>
				<br/>
			</li> 
		<% i++;
			} 
		%>
	</ul>
	<%} %>

<%
	} else {
		Community[] communityArray = (Community[] ) request.getAttribute("community.array");
		//Pattern pattern = Pattern.compile("[a-zA-Z0-9]* ");
		//Matcher matcher = pattern.matcher(user.getLastName());
		//boolean b = matcher.matches(); 
		String email = user.getEmail();
		Pattern pattern = Pattern.compile("\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*");
		Matcher matcher = pattern.matcher(email);
		boolean isEmail = matcher.matches();
%>

<h2><fmt:message key="jsp.mydspace.main.community.heading"/></h2>
<br/>
<div style="margin-left: 30px;">
	<form action="<%=request.getContextPath()%>/eperson-community"
		onsubmit="return checkData('<fmt:message key="jsp.mydspace.main.collection.wizard-basicinfo.community.alert" />', '<fmt:message key="jsp.mydspace.main.collection.wizard-basicinfo.community.alert2" />')" method="post">
		<input type="hidden" name="is_email" value="<%=isEmail %>"/>
		<%
			if(!isEmail){
				boolean f = true;
				boolean f2 = true;
				if(request.getSession().getAttribute("is_email_available") != null) {
					f = (Boolean)request.getSession().getAttribute("is_email_available");
				}
				if(request.getSession().getAttribute("update_email_flag") != null) {
					f2 = (Boolean)request.getSession().getAttribute("update_email_flag");
				}
		%>
			<p><fmt:message key="jsp.mydspace.main.community.html2"/></p>
			<label for="tlogin_email"><strong><fmt:message key="jsp.components.login-form.email"/></strong></label>
			<input type="text" name="email" id="temail" value=""/><font color="red">*</font> 
			<%
				if(!f || !f2){
			%>
			<font color="red"><fmt:message key="jsp.mydspace.main.collection.wizard-basicinfo.community.alert3" /></font>
			<%
				}
			%>
			<br/>
		<%
			}
		
			if(!hasCollection) {
		%>
		<p><fmt:message key="jsp.mydspace.main.community.html"/></p>
		<font color="red">*</font><select name="community_id" id="community_id" onchange="communityList('<%=request.getContextPath() %>',this[selectedIndex].value, '选择机构')">
			<option selected="selected" value="/">
				<fmt:message key="jsp.general.genericScope" />
			</option>

			<%
				for (int i = 0; i < communityArray.length; i++) {
			%>
			<option value="<%=communityArray[i].getID()%>"><%=communityArray[i].getMetadata("name")%></option>
			<%
				}
			%>
		</select>&nbsp;<span id="sub_community"></span> <input type="hidden" id="com_id"
			name="com_id" value="" /> 
		<%
			}
		%>
			<input type="submit"
			value="<fmt:message key="jsp.dspace-admin.general.save"/>" />
	</form>
</div>		
<%
	}
%>

<%
	  if (isAdmin)
	  {
		ServletContext context = request.getSession().getServletContext();
	    ApplicationContext ctx = WebApplicationContextUtils.getWebApplicationContext(getServletContext());
 		ThrottleFilter tf = (ThrottleFilter)ctx.getBean("throttleFilter");
		if(tf != null) {
			Map<String, String> blacklist = tf.getBlackList();
			if(blacklist != null && blacklist.size() > 0) {
	%>
	<h3><fmt:message key="jsp.mydspace.main.heading9"/> [<script>var myDate = new Date();document.write(myDate.toLocaleDateString());</script>]</h3>
	<%
		
	%>
	<ul class="download-blacklist" style="list-style-type: none;">
	<%
			for (Map.Entry<String, String> entry : blacklist.entrySet()) {  
	%>
		<li style="padding-top:5px; margin-top:10px; clear: both;">
			<div style="float:left"><b><%= entry.getKey() %></b></div>
			<div style= "float:left;">&nbsp;&nbsp;--> </div>
			<div style="float:left;"> <span style="color:red"><%= entry.getValue() %></span></div>
		</li>
	<%
				} 
			}
	%>
	</ul>
	<%
		}
	  }
	%>
	
	<script>
		function showMoreClicked(index){
			$('#moreinfo_'+index).toggle( "slow", function() {
				// Animation complete.
			  });
			$('#a1_'+index).toggle();
			$('#a2_'+index).toggle();
		}
		
		function showItemsClicked(index){
			$('#iteminfo_'+index).toggle( "slow", function() {
				// Animation complete.
			  });
			$('#a3_'+index).toggle();
			$('#a4_'+index).toggle();
		}
		
		<% 
			if(!isAdmin && !hasCollection && Community.findAllTop(UIUtil.obtainContext(request)) != null && Community.findAllTop(UIUtil.obtainContext(request)).length > 0) {
		%>
		$(document).ready(function() {
			var id = <%=Community.findAllTop(UIUtil.obtainContext(request))[0].getID() %>;
			$('#community_id').val(id);
			communityList('<%=request.getContextPath() %>', id, '选择单位', '选择机构', false);
		});
		<%
		
			}
		%>
	</script>
	
	</div>
</div>	
</dspace:layout>
