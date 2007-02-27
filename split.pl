##
# split.pl
# 
# $Id$
# 
# @package		MT::Plugin::Split
# @version		0.0.1
# @author		Masayuki Iwai <miyabi@mybdesign.com>
# @copyright	Copyright &copy; 2007 Masayuki Iwai all rights reserved.
# @license		BSD license
##

package MT::Plugin::Split;

use strict;
use MT;

use vars qw($VERSION);
$VERSION = '0.0001';

my $plugin;
eval{
	use MT::Plugin;
	$plugin = MT::Plugin->new(
		name=>'Split', 
		description=>
			'Splits string by delimiter.<br />'.
			'Usage:<br />'.
			'&lt;$MT* split=&quot;&lt;index&gt;[,&lt;delimiter(default:,)&gt;[,&lt;limit(default:0)&gt;]]&quot; $&gt;', 
		author_name=>'M.Iwai', 
		author_link=>'http://www.mybdesign.com/', 
		version=>'0.0.1', 
		config_template=>\&template, 
		settings=>MT::PluginSettings->new([['split_delimiter', {Default=>','}]]), 
	);
	MT->add_plugin($plugin);
};

use MT::Template::Context;
MT::Template::Context->add_global_filter('split'=>\&_split);

sub _split
{
	my ($text, $arg, $ctx) = @_;

	my $config = config('blog:'.$ctx->stash('blog')->id);

	my $index = 0;
	my $delim = $config->{split_delimiter};
	my $limit = 0;

	if($arg =~ /^(.+?)(?:,(.*?)(?:,(.+))?)?$/)
	{
		$index = int($1);
		$delim = $2 if(defined($2) && $2 ne '');
		$limit = int($3) if(defined($3) && $3 > 0);
	}
	else
	{
		$index = int($arg);
	}

	my @temp = split(/\Q$delim\E/, $text, $limit);
	return (($index >= 0 && $index <= $#temp)? $temp[$index]: '');
}

sub template
{
	return <<'__END_OF_DOCUMENT__';
<div class="setting">
	<div class="label"><label for="split_delimiter">Delimiter:</label></div>
	<div class="field">
		<p><input id="split_delimiter" name="split_delimiter" type="text" value="<TMPL_VAR NAME=SPLIT_DELIMITER>" size="4" /></p>
	</div> 
</div>
__END_OF_DOCUMENT__
}

sub config
{
	my $config = {};

	if($plugin)
	{
		require MT::Request;
		my ($scope) = (@_);
		$config = MT::Request->instance->cache('split_config_'.$scope);
		if(!$config)
		{
			$config = $plugin->get_config_hash($scope);
			MT::Request->instance->cache('split_config_'.$scope, $config);
		}
	}

	return $config;
}

1;
