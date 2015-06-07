package ZooKeeper::CLI::Utils;
use strict;
use warnings;
use List::Util qw(reduce);
use base "Exporter::Tiny";

our @EXPORT = qw(
    collapse_path
    get_parent
    is_empty_path
    join_paths
    qualify_path
);

sub collapse_path {
    my ($path) = @_;
    return "" if is_empty_path($path);
    return $path if $path eq '/';
    my @parts = grep {not is_empty_path($_)} split m|/|, $path;

    for (my $i = 0; $i < @parts; $i++) {
        my $part = $parts[$i];
        if ($part eq '.') {
            splice @parts, $i, 1;
            $i -= 1;
        } elsif ($part eq '..') {
            splice @parts, $i - 1, 2;
            $i -= 2;
        }
    }

    my $collapsed = reduce {join_paths($a, $b)} @parts;
    $collapsed = "/$collapsed" if $path =~ m#^/#;
    return $collapsed || '/';
}

sub get_parent {
    my ($node) = @_;
    return $node if $node =~ s#(?<=.)/$##;

    if ($node =~ m#^/#) {
        (my $parent = $node) =~ s#/[^/]+$#/#;
        $parent =~ s#(?<=.)/$##;
        return $parent || '';
    } else {
        return '' unless $node =~ m#/#;
        (my $parent = $node) =~ s#/[^/]+$#/#;
        $parent =~ s#(?<=.)/$##;
        return $parent || '';
    }
}

sub join_paths {
    my ($a, $b) = @_;
    return $b if is_empty_path($a);
    return $a if is_empty_path($b);
    $a .= '/' unless $a =~ m|/$|;
    $b =~ s|^/||;
    return $a . $b;
}

sub qualify_path {
    my ($path, $current_node) = @_;
    my $qualified = substr($path, 0, 1) eq '/' ? $path : join_paths($current_node, $path);
    return collapse_path($qualified);
}

sub is_empty_path {
    my ($path) = @_;
    return not(defined $path) || $path eq "";
}

1;