#   Copyright (c) 2008 ToI-Planning, All rights reserved.
# 
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
# 
#   1. Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#
#   3. Neither the name of the authors nor the names of its contributors
#      may be used to endorse or promote products derived from this
#      software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
#   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  $Id$

package Locator::L10N::ja;

use strict;
use base 'Locator::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
	'toi-planning' => 'ToI企画',

	'location ties to the author/blog/entry.' =>
	'ユーザー/ブログ/エントリーに地図を設定できるようにします。',

	'locator-field address' => '住所',
	'locator-field map' => '地図',
	'locator-field zoom' => 'ズーム',
    'locator-show latlng' => '緯度と経度',
    'locator-show zoom' => 'ズーム',
    'Latitude' => '緯度',
    'Longitude' => '経度',

	'locator-field not to use' => '使わない',
	'locator-field use' => '使う',
	'locator-field not to show' => '表示しない',
	'locator-field show' => '表示する',
	'locator-field any' => '任意で設定可能',
	'locator-field required' => '必須項目',

	'Which context enable locator-field for' => 'どのコンテキストで関連付けを有効にするか',
	'for author' => 'ユーザー',
	'for blog' => 'ブログ',
	'for entry' => 'エントリー',
	'for page' => 'ウェブページ',
	'Which blogs for entry' => 'エントリーへの関連付けを有効にするブログ',
	'Which blogs for page' => 'ウェブページへの関連付けを有効にするブログ',
	'GoogleMap Client ID' => 'Premier の Client ID',
	'GoogleMap Crypto key' => 'Premier の Crypto key',

	'Client ID(When this blog has specific ID)' => 'Client ID<br/>(このブログが独自に Client ID 必要とする場合)',
	'Crypto key(When this blog has specific key)' => 'Crypto key<br/>(このブログが独自に Crypto key を必要とする場合)',

	'Map' => '地図',
	'Address' => '住所',
	'Zoom' => 'ズーム',

	'Location default latitude' => '35.674311',
	'Location default longitude' => '136.862834',
	'Location default zoomlevel' => '17',
	
	'Please ensure address fields have been filled in.' => '住所は必須項目です',
	'Please ensure map fields have been filled in.' => '地図は必須項目です',

	'Set this location' => 'この場所を指定する',
	'Unset this location' => '指定を解除する',

	'updated' => '更新されました',
	'Unset this location OK?' => '指定を解除してもよろしいですか？',

	'Zoom has changed. Did you update zoom value?' =>
	'ズームが変更されました。この値で更新しますか？',
	'update' => '更新',

	'Insert into (for entry)' => '地図の表示位置(ブログ記事)',
	'Under Text/More' => '本文の下',
	'On Buttons' => '保存ボタンの上',
);

1;
