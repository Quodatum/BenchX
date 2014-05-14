<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
	xmlns:wadl="http://wadl.dev.java.net/2009/02" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
	exclude-result-prefixes="xs wadl fn" version="2.0">


	<xsl:param name="root" as="xs:string" />

	<!-- generate module html // -->
	<xsl:template match="/wadl:application/wadl:resources">
		<div>
			<h2>
				
				Base: <xsl:value-of select="@base"/>
				
			</h2>
			<xsl:for-each select="wadl:resource[starts-with(@path,$root)]">
			<xsl:value-of select="@path"/>
			</xsl:for-each>

		</div>
	</xsl:template>

</xsl:stylesheet>
