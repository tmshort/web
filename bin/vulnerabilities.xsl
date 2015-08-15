<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output indent="yes" encoding="UTF-8" method="html" omit-xml-declaration="yes"/>

  <!-- Format a date like "1960-02-10" into "February 10th, 1960" -->
  <xsl:template name="dateformat">
    <xsl:param name="date" select="."/>
    <xsl:variable name="day" select="number(substring($date,7,2))"/>
    <xsl:variable name="month" select="number(substring($date,5,2))"/>
    <xsl:variable name="year" select="number(substring($date,1,4))"/>

    <xsl:if test="$day &gt; 0"> 
      <xsl:value-of select="$day" />
      <xsl:choose>
	<xsl:when test="$day=1 or $day=21 or $day=31">st</xsl:when>
	<xsl:when test="$day=2 or $day=22">nd</xsl:when>
	<xsl:when test="$day=3 or $day=23">rd</xsl:when>
	<xsl:otherwise>th</xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$month=01">January</xsl:when>
      <xsl:when test="$month=02">February</xsl:when>
      <xsl:when test="$month=03">March</xsl:when>
      <xsl:when test="$month=04">April</xsl:when>
      <xsl:when test="$month=05">May</xsl:when>
      <xsl:when test="$month=06">June</xsl:when>
      <xsl:when test="$month=07">July</xsl:when>
      <xsl:when test="$month=08">August</xsl:when>
      <xsl:when test="$month=09">September</xsl:when>
      <xsl:when test="$month=10">October</xsl:when>
      <xsl:when test="$month=11">November</xsl:when>
      <xsl:when test="$month=12">December</xsl:when>
    </xsl:choose>
    <xsl:if test="$year&gt;0">
      <xsl:text> </xsl:text>
      <xsl:value-of select="$year"/>
    </xsl:if>
  </xsl:template>

  <xsl:key name="unique-date" match="@public" use="substring(.,1,4)"/>
  <xsl:key name="unique-base" match="@base" use="."/>

  <xsl:template match="security">
    <xsl:comment>
      Do not edit this file; edit vulnerabilities.xml
    </xsl:comment>

    <h3><a name="toc">Table of Contents</a></h3>
    <ul>
      <xsl:for-each select="issue/@public[generate-id()=generate-id(key('unique-date',substring(.,1,4)))]">
	<xsl:sort select="." order="descending"/>
	<xsl:variable name="year" select="substring(.,1,4)"/>
	<li><a href="#y{$year}"><xsl:value-of select="$year"/></a></li>
      </xsl:for-each>
    </ul>

    <xsl:for-each select="issue/@public[generate-id()=generate-id(key('unique-date',substring(.,1,4)))]">
      <xsl:sort select="." order="descending"/>
      <xsl:variable name="year" select="substring(.,1,4)"/>

      <h3><a name="y{$year}"><xsl:value-of select="$year"/></a>
	<!-- don't need an UP on each year.
	<xsl:text>  </xsl:text><a href="#toc"><img src="/img/up.gif"/></a>
	-->
      </h3>
      <dl>
	<xsl:apply-templates select="../../issue[substring(@public,1,4)=$year]">
	  <xsl:sort select="./@public" order="descending"/>
	</xsl:apply-templates>
      </dl>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="issue">
    <dt>
      <xsl:apply-templates select="cve"/>
      <xsl:if test="advisory/@url">
	<xsl:text> </xsl:text><a href="{advisory/@url}">(OpenSSL advisory) </a>
      </xsl:if>
      <xsl:if test="impact/@severity">
	[<xsl:value-of select="impact/@severity"/> severity]
      </xsl:if>
      <xsl:call-template name="dateformat">
	<xsl:with-param name="date" select="@public"/>
      </xsl:call-template>
      <xsl:text disable-output-escaping='yes'>:  &lt;a href="#toc">&lt;img src="/img/up.gif"/>&lt;/a></xsl:text>
    </dt>
    <dd>
      <xsl:copy-of select="string(description)"/>
      <xsl:if test="reported/@source">
	Reported by <xsl:value-of select="reported/@source"/>.
      </xsl:if>
      <ul>
	<xsl:for-each select="fixed">
	  <li>Fixed in OpenSSL  
	    <xsl:value-of select="@version"/>
	    <xsl:if test="git/@hash">
	      <xsl:text> </xsl:text><a href="https://github.com/openssl/openssl/commit/{git/@hash}">(git commit)</a><xsl:text> </xsl:text>
	    </xsl:if>
	    <xsl:variable name="mybase" select="@base"/>
	    <xsl:for-each select="../affects[@base=$mybase]|../maybeaffects[@base=$mybase]">
	      <xsl:sort select="@version" order="descending"/>
	      <xsl:if test="position() =1">
		<xsl:text> (Affected </xsl:text>
	      </xsl:if>
	      <xsl:value-of select="@version"/>
	      <xsl:if test="name() = 'maybeaffects'">
		<xsl:text>?</xsl:text>
	      </xsl:if>
	      <xsl:if test="position() != last()">
		<xsl:text>, </xsl:text>
	      </xsl:if>
	      <xsl:if test="position() = last()">
		<xsl:text>) </xsl:text>
	      </xsl:if>
	    </xsl:for-each>
	  </li>
	</xsl:for-each>
      </ul>
    </dd>
  </xsl:template>

  <xsl:template match="cve">
    <xsl:if test="@name != ''">
      <b><a name="{@name}">
	  <xsl:if test="@description = 'full'">
	    The Common Vulnerabilities and Exposures project
	    has assigned the name 
	  </xsl:if>
	  <a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-{@name}">CVE-<xsl:value-of select="@name"/> </a>
	  <xsl:if test="@description = 'full'">
	    to this issue.
	  </xsl:if>
      </a></b>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
