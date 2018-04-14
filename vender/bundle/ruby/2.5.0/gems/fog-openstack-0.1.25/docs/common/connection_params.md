### Optional Connection Parameters

Fog supports passing additional connection parameters to its underlying HTTP library (Excon) using the `:connection_options` parameter.

<table>
	<tr>
		<th>Key</th>
		<th>Description</th>
	</tr>
	<tr>
		<td>:connect_timeout</td>
		<td>Connection timeout (default: 60 seconds)</td>
	</tr>
	<tr>
		<td>:read_timeout</td>
		<td>Read timeout for connection (default: 60 seconds)</td>	</tr>
	<tr>
		<td>:write_timeout</td>
		<td>Write timeout for connection (default: 60 seconds)</td>
	</tr>
	<tr>
		<td>:proxy</td>
		<td>Proxy for HTTP and HTTPS connections</td>
	</tr>
	<tr>
		<td>:ssl_ca_path</td>
		<td>Path to SSL certificate authorities</td>
	</tr>
	<tr>
		<td>:ssl_ca_file</td>
		<td>SSL certificate authority file</td>
	</tr>
	<tr>
		<td>:ssl_verify_peer</td>
		<td>SSL verify peer (default: true)</td>
	</tr>
  <tr>
    <td>:debug_request</td>
    <td>debug print request (default: false)</td>
  </tr>
  <tr>
    <td>:debug_response</td>
    <td>debug print response (default: false)</td>
  </tr>
</table>
