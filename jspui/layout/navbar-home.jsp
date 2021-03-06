<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Default navigation bar
--%>

<%@page import="org.apache.commons.lang.StringUtils"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="/WEB-INF/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Collection" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.eperson.EPerson" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.BrowseIndex" %>
<%@ page import="org.dspace.browse.BrowseInfo" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.net.URLEncoder" %>


<%
    // Is anyone logged in?
    EPerson user = (EPerson) request.getAttribute("dspace.current.user");

    // Is the logged in user an admin
    Boolean admin = (Boolean)request.getAttribute("is.admin");
    boolean isAdmin = (admin == null ? false : admin.booleanValue());

    // Get the current page, minus query string
    String currentPage = UIUtil.getOriginalURL(request);
    int c = currentPage.indexOf( '?' );
    if( c > -1 )
    {
        currentPage = currentPage.substring( 0, c );
    }

    // E-mail may have to be truncated
    String navbarEmail = null;

    if (user != null)
    {
        navbarEmail = user.getEmail();
    }
    
    // get the browse indices
    
	BrowseIndex[] bis = BrowseIndex.getBrowseIndices();
    BrowseInfo binfo = (BrowseInfo) request.getAttribute("browse.info");
    String browseCurrent = "";
    if (binfo != null)
    {
        BrowseIndex bix = binfo.getBrowseIndex();
        // Only highlight the current browse, only if it is a metadata index,
        // or the selected sort option is the default for the index
        if (bix.isMetadataIndex() || bix.getSortOption() == binfo.getSortOption())
        {
            if (bix.getName() != null)
    			browseCurrent = bix.getName();
        }
    }
 // get the locale languages
    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Locale sessionLocale = UIUtil.getSessionLocale(request);
    
%>
		
       <div class="navbar-header">
         <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
         </button>
         <a href="<%=request.getContextPath() %>" class="navbar-brand"><img height="38" alt="calis logo" src="<%=request.getContextPath() %>/calis/images/logo-title.png"></a>
       </div>
       <nav class="collapse navbar-collapse bs-navbar-collapse navbar-collapse-home" role="navigation">
         <ul class="nav navbar-nav">
           <li class=""><a href="<%= request.getContextPath() %>/simple-search"><fmt:message key="nsfc.layout.navbar-default.search"/></a></li>
           <li><a class="" href="<%= request.getContextPath() %>/researcher-list"><fmt:message key="jsp.layout.navbar-default.researchers" /></a></li>     
           <li class="dropdown">
             <a href="#" class="dropdown-toggle" data-toggle="dropdown"><fmt:message key="jsp.layout.navbar-default.browse"/> <b class="caret"></b></a>
             <ul class="dropdown-menu">
               <li><a href="<%= request.getContextPath() %>/community-list"><fmt:message key="jsp.layout.navbar-default.communities-collections"/></a></li>
				<li class="divider"></li>
        <li class="dropdown-header"><fmt:message key="jsp.layout.navbar-default.browseitemsby"/></li>
				<%-- Insert the dynamic browse indices here --%>
				
				<%
					for (int i = 0; i < bis.length; i++)
					{
						BrowseIndex bix = bis[i];
						String key = "browse.menu." + bix.getName();
						if(bix.getName().equals("author") || bix.getName().equals("subject")) {
					%>
								<li><a href="<%= request.getContextPath() %>/browse?type=<%= bix.getName() %>&order=ASC&rpp=20&starts_with=A"><fmt:message key="<%= key %>"/></a></li>
					<%
						} else {
					%>
				      			<li><a href="<%= request.getContextPath() %>/browse?type=<%= bix.getName() %>"><fmt:message key="<%= key %>"/></a></li>
					<%	
						}	
					}
				%>
				    
				<%-- End of dynamic browse indices --%>

            </ul>
          </li>
          <li class=""><a href="<%=request.getContextPath()%>/guide"><fmt:message key="jsp.layout.navbar-default.help" /></a></li>
       </ul>

        <div class="nav navbar-nav navbar-right">
		<ul class="nav navbar-nav navbar-right">
         <li class="dropdown">
         <%
    if (user != null)
    {
		%>
		<a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <fmt:message key="jsp.layout.navbar-default.loggedin">
		      <fmt:param><%= StringUtils.abbreviate(navbarEmail, 20) %></fmt:param>
		  </fmt:message> <b class="caret"></b></a>
		<%
    } else {
		%>
             <a href="#" class="dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-user"></span> <fmt:message key="jsp.layout.navbar-default.sign"/> <b class="caret"></b></a>
	<% } %>             
             <ul class="dropdown-menu">
               <li><a href="<%= request.getContextPath() %>/mydspace"><fmt:message key="jsp.layout.navbar-default.users"/></a></li>
               <li><a href="<%= request.getContextPath() %>/subscribe"><fmt:message key="jsp.layout.navbar-default.receive"/></a></li>
               <%-- 
               <li><a href="<%= request.getContextPath() %>/profile"><fmt:message key="jsp.layout.navbar-default.edit"/></a></li>
               --%>

		<%
		  if (isAdmin)
		  {
		%>
			   <li class="divider"></li>  
               <li><a href="<%= request.getContextPath() %>/dspace-admin"><fmt:message key="jsp.administer"/></a></li>
		<%
		  }
		  if (user != null) {
		%>
		<li><a href="<%= request.getContextPath() %>/logout"><span class="glyphicon glyphicon-log-out"></span> <fmt:message key="jsp.layout.navbar-default.logout"/></a></li>
		<% } %>
             </ul>
           </li>
          </ul>
	
	</div>
	
	<% if (supportedLocales != null && supportedLocales.length > 1)
	     {
	 %>
	    <div class="nav navbar-nav navbar-right navbar-right-language">
	    	<ul class="nav navbar-nav">
      		<li class="">
	 <%   for (int i = 0; i < supportedLocales.length; i++)
	     {
		 if(i!=0)out.print("|");
	 %>
	        <a style="display: inline-block;" onclick="changeLanguage('<%=supportedLocales[i].toString()%>')" href="javascript:void(0);">
	         <%= supportedLocales[i].getDisplayLanguage(supportedLocales[i])%>
	       </a>
	 <%
	     }
	 %>
	 		</li>
	 		</ul>
	 		<form method="get" name="repost" action="">
		   		<input type="hidden" name="type" />
		   		<input type="hidden" name="sort_by" />
		   		<input type="hidden" name="order" />
		   		<input type="hidden" name="rpp" />
		   		<input type="hidden" name="etal" />	
		   		<input type="hidden" name="null" />
		   		<input type="hidden" name="offset" />
		   		<input type="hidden" name="starts_with" />
		   		<input type="hidden" name="value" />
				<input type="hidden" name="locale" />
			</form>
		  </div>
		 <%
		   }
		 %>
    </nav>