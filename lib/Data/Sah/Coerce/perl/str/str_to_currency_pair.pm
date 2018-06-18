package Data::Sah::Coerce::perl::str::str_to_currency_pair;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub meta {
    +{
        v => 3,
        enable_by_default => 0,
        might_fail => 1,
        prio => 50,
    };
}

sub coerce {
    my %args = @_;

    my $dt = $args{data_term};

    my $res = {};

    $res->{expr_match} = "!ref($dt)";
    $res->{modules}{"Locale::Codes::Currency_Codes"} //= 0;
    $res->{expr_coerce} = join(
        "",
        "do { my \$res; ",
        "  my (\$cur1, \$cur2) = $dt =~ m!\\A(\\S+)/(\\S+)\\z! or do { \$res = ['Invalid currency pair syntax, please use CUR1/CUR2 syntax']; goto RETURN_RES }; ",

        # check currency1 differs from currency2
        "  if (\$cur1 eq \$cur2) { \$res = ['Base currency and quote currency must differ']; goto RETURN_RES } ",

        # check currency1
        "  \$cur1 = uc \$cur1; ",
        "  unless (\$Locale::Codes::Data{currency}{code2id}{alpha}{\$cur1}) { ",
        "    \$res = ['Unknown base currency code: ' . \$cur1]; goto RETURN_RES; ",
        "  } ",

        # check currency2
        "  \$cur2 = uc \$cur2; ",
        "  unless (\$Locale::Codes::Data{currency}{code2id}{alpha}{\$cur2}) { ",
        "    \$res = ['Unknown quote currency code: ' . \$cur2]; goto RETURN_RES; ",
        "  } ",

        "  \$res = [undef, \"\$cur1/\$cur2\"]; ",

        "  RETURN_RES: \$res; ",
        "}",
    );

    $res;
}

1;
# ABSTRACT: Coerce string into currency pair, e.g. USD/IDR

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

This coercion rules checks that:

=over

=item * string is in the form of "I<currency1>/I<currency2>"

=item * I<currency1> is not the same as I<currency2>

=item * I<currency1> is a known currency code

=item * I<currency2> is a known currency code

=back

The rule is not enabled by default. You can enable it in a schema using e.g.:

 ["str", "x.perl.coerce_rules"=>["str_to_currency_pair"]]
