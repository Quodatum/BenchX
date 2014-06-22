<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- convert components.xml to bootstrap html -->
	<xsl:template match="/components">
		<div>
			<h2>Components</h2>
			<div>
				<xsl:apply-templates select="cmp[not(@disabled)]">
					<xsl:sort select="@name" />
				</xsl:apply-templates>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="cmp">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">
					<xsl:value-of select="@name" />
					<span class="badge">
						<xsl:value-of select="@version" />
					</span>
				</h3>
			</div>
			<div class="panel-body">
				<p>
					<xsl:value-of select="tagline" />
				</p>
				<a href="{home}" target="benchx-doc">
					<xsl:value-of select="home" />
				</a>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>