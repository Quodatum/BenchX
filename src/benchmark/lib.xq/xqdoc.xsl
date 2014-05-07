<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
	xmlns:doc="http://www.xqdoc.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
	exclude-result-prefixes="xs doc fn" version="2.0">


	<xsl:param name="source" as="xs:string" />

	<!-- generate module html // -->
	<xsl:template match="//doc:xqdoc">
		<div>
			<h2>Library Module: int_set/jpcs.xqm</h2>
			<table>
				<tr>
					<td>
						<b>URI:</b>
					</td>
					<td>
						<code>http://www.woerteler.de/xquery/modules/int-set/jpcs</code>
					</td>
				</tr>
				<tr>
					<td>
						<b>Description:</b>
					</td>
					<td>Implementation of a set of integers based on John Snelson's
						Red-Black Tree.
					</td>
				</tr>
				<tr>
					<td>
						<b>Author:</b>
					</td>
					<td>Leo Woerteler &lt;leo@woerteler.de&gt;</td>
				</tr>
				<tr>
					<td>
						<b>Version:</b>
					</td>
					<td>0.1</td>
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
			<h3>contains($set, $x)</h3>
			<table>
				<tr>
					<td>
						<b>Arguments:</b>
					</td>
					<td>
						<table>
							<tr>
								<td>
									<code>$set</code>
								</td>
								<td>
									<code>item()*</code>
								</td>
								<td>the Red-Black Tree</td>
							</tr>
							<tr>
								<td>
									<code>$x</code>
								</td>
								<td>
									<code>xs:integer</code>
								</td>
								<td>the integer</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<b>Returns:</b>
					</td>
					<td>
						<table>
							<tr>
								<td>
									<code>item()*</code>
								</td>
								<td>
									<code>true()</code>
									if the integer is contained in the tree,
									<code>false()</code>
									otherwise
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<b>Description:</b>
					</td>
					<td>Checks if the given integer is contained in the given Red-Black
						Tree.
					</td>
				</tr>
			</table>
		</div>
	</xsl:template>
	
	<xsl:template match="xqdoc:parameters">
		<table>
			<tr>
				<td>
					<code>$set</code>
				</td>
				<td>
					<code>item()*</code>
				</td>
				<td>the Red-Black Tree</td>
			</tr>
			<tr>
				<td>
					<code>$x</code>
				</td>
				<td>
					<code>xs:integer</code>
				</td>
				<td>the integer</td>
			</tr>
		</table>
	</xsl:template>

</xsl:stylesheet>
