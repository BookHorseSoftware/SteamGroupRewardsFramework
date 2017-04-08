<?php

$response = [];

header('Content-type: application/json');

$response['status'] = 'error';

if (!isset($_GET['steamid'])) {
	$response['message'] = 'Missing SteamID parameter.';
	$response['comment'] = 'Accepted formats are: SteamID, SteamID64, SteamID3 (without U:1:)';
} elseif (!isset($_GET['group'])) {
	$response['message'] = 'Missing group parameter.';
	$response['comment'] = 'Accepted formats are: Group custom URL, Group ID';
}

if (isset($response['message'])) {
	http_response_code(400);
	echo json_encode($response);
	die();
}

$user  = $_GET['steamid'];
$group = $_GET['group'];

$response['status'] = 'failed';
$response['user']   = $user;
$response['group']  = $group;

$endpoint = is_numeric($group) ? 'gid' : 'groups';

$xml = simplexml_load_file("http://steamcommunity.com/$endpoint/$group/memberslistxml/?xml=1");

if ($xml) {
	if ((string) $xml->groupDetails->groupName) {
		$response['status']  = 'success';
		$response['inGroup'] = false;

		foreach ($xml->members->steamID64 as $steamid) {
			if ($user == $steamid) {
				$response['inGroup'] = true;
				break;
			}
		}
	} else {
		http_response_code(404);
		$response['message'] = 'Valid XML returned containing invalid group details. Does the group exist?';
		$response['comment'] = 'This is a problem with Valve\'s Community API - passing a numeric group ID results in a successful request every time regardless of whether or not the group *actually* exists, because apparently they hired a monkey as an API designer. Volvo pls fix thx';
	}
} else {
	http_response_code(404);
	$response['message'] = 'Failed to load/parse XML data. Does the group exist?';
}

echo json_encode($response);