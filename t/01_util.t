use Test::More tests => 18;

use OAuth::Lite::Util;

my $random1 = OAuth::Lite::Util::gen_random_key();
is(length($random1), 20);
like($random1, qr/^[0-9a-zA-Z]{20}$/);

my $random2 = OAuth::Lite::Util::gen_random_key(10);
is(length($random2), 20);
like($random2, qr/^[0-9a-zA-Z]{20}$/);

my $random3 = OAuth::Lite::Util::gen_random_key(8);
is(length($random3), 16);
like($random3, qr/^[0-9a-zA-Z]{16}$/);

my $param = q{123 @#$%&hoge hoge+._-~};
my $encoded = OAuth::Lite::Util::encode_param($param);
is($encoded, q{123%20%40%23%24%25%26hoge%20hoge%2B._-~});
my $decoded = OAuth::Lite::Util::decode_param($encoded);
is($decoded, $param);


my $http_method = "GET";
my $request_url = "http://photos.example.net/photos";
my $params = {
	oauth_consumer_key     => 'dpf43f3p214k3103',
	oauth_token            => 'nnch734d00s12jdk',
	oauth_signature_method => 'HMAC-SHA1',
	oauth_timestamp        => '1191242096',
	oauth_nonce            => 'kllo9940pd9333jh',
	oauth_version          => '1.0',
	file                   => 'vacation.jpg',
	size                   => 'original',
};

my $base = OAuth::Lite::Util::create_signature_base_string($http_method, $request_url, $params);
is($base, q{GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p214k3103%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00s12jdk%26oauth_version%3D1.0%26size%3Doriginal});

delete $params->{file};
delete $params->{size};

my $head = sprintf(q{OAuth realm="http://example.com/realm"});
my $header = join(", ", $head, (map sprintf(q{%s="%s"}, $_, OAuth::Lite::Util::encode_param($params->{$_})), keys %$params));
my ($realm, $parsed) = OAuth::Lite::Util::parse_auth_header($header);
is($realm, 'http://example.com/realm');
is($parsed->{oauth_consumer_key},     'dpf43f3p214k3103');
is($parsed->{oauth_token},            'nnch734d00s12jdk');
is($parsed->{oauth_signature_method}, 'HMAC-SHA1');
is($parsed->{oauth_timestamp},        '1191242096');
is($parsed->{oauth_nonce},            'kllo9940pd9333jh');
is($parsed->{oauth_version},          '1.0');

my $params_include_array = {
	oauth_consumer_key     => 'dpf43f3p214k3103',
	oauth_token            => 'nnch734d00s12jdk',
	oauth_signature_method => 'HMAC-SHA1',
	oauth_timestamp        => '1191242096',
	oauth_nonce            => 'kllo9940pd9333jh',
	oauth_version          => '1.0',
	file                   => 'vacation.jpg',
	size                   => 'original',
  selected               => [ 1, 2, 3 ],
};

my $base2 = OAuth::Lite::Util::create_signature_base_string($http_method, $request_url, $params_include_array);
is($base2, q{GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p214k3103%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00s12jdk%26oauth_version%3D1.0%26selected%3D1%26selected%3D2%26selected%3D3%26size%3Doriginal});

my $params_include_invalidtype = {
	oauth_consumer_key     => 'dpf43f3p214k3103',
	oauth_token            => 'nnch734d00s12jdk',
	oauth_signature_method => 'HMAC-SHA1',
	oauth_timestamp        => '1191242096',
	oauth_nonce            => 'kllo9940pd9333jh',
	oauth_version          => '1.0',
	file                   => 'vacation.jpg',
	size                   => 'original',
    selected               => { unknown => 'type' },
};

my $base3 = OAuth::Lite::Util::create_signature_base_string($http_method, $request_url, $params_include_invalidtype);
# throughed unknown type
is($base3, q{GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p214k3103%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00s12jdk%26oauth_version%3D1.0%26size%3Doriginal});

