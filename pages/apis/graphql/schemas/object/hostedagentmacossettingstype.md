---
#  _____   ____    _   _  ____ _______   ______ _____ _____ _______
#  |  __  / __   |  | |/ __ __   __| |  ____|  __ _   _|__   __|
#  | |  | | |  | | |  | | |  | | | |    | |__  | |  | || |    | |
#  | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
#  | |__| | |__| | | |  | |__| | | |    | |____| |__| || |_   | |
#  |_____/ ____/  |_| _|____/  |_|    |______|_____/_____|  |_|
#  This file is auto-generated by script/generate_graphql_api_content.sh,
#  please build the schema.graphql by running `rails graphql:update_reference_schema`
#  with https://github.com/buildkite/buildkite/,
#  replace the content in data/schema.graphql
#  and run the generation script `./scripts/generate-graphql-api-content.sh`.

title: HostedAgentMacOSSettingsType – Objects – GraphQL API
toc: false
---
<!-- vale off -->
<h1 class="has-pills">
  HostedAgentMacOSSettingsType
  <span data-algolia-exclude><span class="pill pill--object pill--normal-case pill--large"><code>OBJECT</code></span></span>
</h1>
<!-- vale on -->


Configuration options for the base image of hosted agent instances on macOS platforms.

<table class="responsive-table responsive-table--single-column-rows">
  <thead>
    <th>
      <h2 data-algolia-exclude>Fields</h2>
    </th>
  </thead>
  <tbody>
    <tr><td><h3 class="is-small has-pills"><code>macosVersion</code><a href="/docs/apis/graphql/schemas/enum/hostedagentmacosversion" class="pill pill--enum pill--normal-case pill--medium" title="Go to ENUM HostedAgentMacOSVersion"><code>HostedAgentMacOSVersion</code></a></h3><p>The macOS version to use for macOS hosted agent instances for this cluster queue.</p></td></tr><tr><td><h3 class="is-small has-pills"><code>xcodeVersion</code><a href="/docs/apis/graphql/schemas/scalar/string" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR String"><code>String</code></a></h3><p>The Xcode version to pre-select (via xcode-select) on macOS hosted agent instances for this cluster queue.</p></td></tr>
  </tbody>
</table>
