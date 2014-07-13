<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- convert components.xml to bootstrap html -->
	<xsl:template match="/components">

		<div>
			<xsl:for-each select="//depends[not(. =//cmp/@name)]">
				<span class="label label-error">
					<xsl:value-of select="." />
				</span>
			</xsl:for-each>
			<h2>
				Components (
				<xsl:value-of select="count(cmp[not(@disabled)])" />
				)
			</h2>
			<div>
				<xsl:apply-templates select="cmp[not(@disabled)]">
					<xsl:sort select="lower-case(@name)" />
				</xsl:apply-templates>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="cmp">
		<div class="panel panel-default">
			<div class="panel-heading">

				<h4 class="panel-title">
					<a class="anchor" id="cmp-{@name}"></a>
					<a ng-click="scrollTo('cmp-{@name}')">
						<xsl:value-of select="@name" />
					</a>
					<span class="badge">
						<xsl:value-of select="@version" />
					</span>
				</h4>
			</div>
			<div class="panel-body">
				<p>
					<xsl:value-of select="tagline" />
				</p>
				<a href="{home}" target="benchx-doc" class="badge">
					<i class="glyphicon glyphicon-home"></i>
					Home
				</a>
				<span>
					Licence:
					<span class="badge">
						<xsl:value-of select="licence" />
					</span>
				</span>
				<span>
					Runat:
					<span class="badge">
						<xsl:value-of select="runat" />
					</span>
				</span>
				<div>
					CDN:
					<a href="{cdn}">
						<xsl:value-of select="cdn" />
					</a>
				</div>
				<div>
					Used by:
					<xsl:for-each select="//cmp[depends=current()/@name]">
						<xsl:sort select="@name" />
						<a ng-click="scrollTo('cmp-{@name}')" class="label label-info">
							<xsl:value-of select="@name" />
						</a>
					</xsl:for-each>
				</div>
				<div>
				    Depends on:
                    <xsl:for-each select="depends">
                        <xsl:sort select="@name" />
                        <a ng-click="scrollTo('cmp-{.}')" class="label label-info">
                            <xsl:value-of select="." />
                        </a>
                    </xsl:for-each>
				</div>
			</div>

		</div>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>