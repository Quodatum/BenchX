<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xqdoc="http://www.xqdoc.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
	exclude-result-prefixes="xs xqdoc fn" version="2.0">


	<xsl:param name="source" as="xs:string" />

	<!-- generate module html // -->
	<xsl:template match="//xqdoc:xqdoc">
		<div>
			<h2>
				<xsl:value-of select="xqdoc:module/@type" />
				Module:
				<xsl:value-of select="xqdoc:module/xqdoc:name" />
			</h2>
			<table>
				<tr>
					<td>
						<b>URI:</b>
					</td>
					<td>
						<code>
							<xsl:value-of select="xqdoc:module/xqdoc:uri" />
						</code>
					</td>
				</tr>
				<tr>
					<td>
						<b>Description:</b>
					</td>
					<td>
						<xsl:value-of select="xqdoc:module/xqdoc:comment/xqdoc:description" />
					</td>
				</tr>
				<tr>
					<td>
						<b>Author:</b>
					</td>
					<td>
						<xsl:value-of select="xqdoc:module/xqdoc:comment/xqdoc:author" />
					</td>
				</tr>
				<tr>
					<td>
						<b>Version:</b>
					</td>
					<td>
						<xsl:value-of select="xqdoc:module/xqdoc:comment/xqdoc:version" />
					</td>
				</tr>
			</table>
			<h2>Variables</h2>
			<h3>$LT</h3>
			<table>
				<tr>
					<td>
						<b>Type:</b>
					</td>
					<td>
						<code>item()</code>
					</td>
				</tr>
			</table>
			<h2>Functions</h2>
			<xsl:for-each select="xqdoc:functions/xqdoc:function">
				<xsl:sort select="xqdoc:name" />
				<xsl:apply-templates select="." />
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="xqdoc:function">
		<h3>
			<!-- <xsl:value-of select="xqdoc:signature" /> -->
			<xsl:value-of select="xqdoc:name" />
			<xsl:text>(</xsl:text>
			<xsl:for-each select="xqdoc:parameters/xqdoc:parameter">
				<xsl:value-of select="xqdoc:name" />
				<xsl:text>,</xsl:text>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</h3>
		<table>
			<xsl:apply-templates select="xqdoc:parameters" />

			<tr>
				<td>
					<b>Returns:</b>
				</td>
				<td>
					<table>
						<tr>
							<td>
								<xsl:apply-templates select="xqdoc:return/xqdoc:type" />
							</td>
							<td>
								<xsl:value-of select="xqdoc:comment/xqdoc:return" />
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<b>Description:</b>
				</td>
				<td>
					<xsl:value-of select="xqdoc:comment/xqdoc:description" />
				</td>
			</tr>
		</table>
	</xsl:template>

	<xsl:template match="xqdoc:parameters">
		<tr>
			<td>
				<b>Arguments:</b>
			</td>
			<td>

				<table>
					<xsl:for-each select="xqdoc:parameter">
						<tr>
							<td>
								<code>
									<xsl:value-of select="xqdoc:name" />
								</code>
							</td>
							<td>
								<xsl:apply-templates select="xqdoc:type" />
							</td>
							<td>
								<!-- @TODO better -->
								<xsl:value-of select="../xqdoc:comment/xqdoc:param/text()" />
							</td>
						</tr>

					</xsl:for-each>
				</table>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="xqdoc:type">
		<code>
			<xsl:value-of select="." />
			<xsl:value-of select="@occurance" />
		</code>
	</xsl:template>
</xsl:stylesheet>
