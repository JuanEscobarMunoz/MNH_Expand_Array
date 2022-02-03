########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m MNH.pm <files>
########################################################################
package MNH;

use strict;

# version number of module
my $VERSION = '1.0.0';

require "function.pm";

# Default Slide parameter <-> @D(ii=iib:iie:iis,ij ,ijb:ije:ijs , ...)
my @MNH_slide_default_on    = () ;
my @MNH_slide_default_name  = () ;
my @MNH_slide_default_begin = () ;  
my @MNH_slide_default_end   = () ;
my @MNH_slide_default_step  = () ;
my @MNH_slide_default_index  = () ;

# Left slide parameter <-> @L(A(:,:,:)) =
my $MNH_slide_left_array  = "" ;
my @MNH_slide_left_on    = () ;
my @MNH_slide_left_begin = () ;  
my @MNH_slide_left_end   = () ;
my @MNH_slide_left_step  = () ;
my @MNH_slide_left_index  = () ;

# Right slide parameter <-> = @R(B(:,:,:)) 
my $MNH_slide_right_array  = "" ;
my @MNH_slide_right_on    = () ;
my @MNH_slide_right_begin = () ;  
my @MNH_slide_right_end   = () ;
my @MNH_slide_right_step  = () ;
my @MNH_slide_right_index  = () ;
 
########################################################################
# Set_slide_default all input, usage: - ANY NUMBER OF INPUTS
# Set_slide_default(ii=nib:nie:ip ,ij=njb:nje,jp, ik=nkb:nke,kp ....)
# if dim doesn't contain ':' , slide is not activate
########################################################################
sub Set_slide_default
{
    my $liste = '';
    my $slide;

    my $slide_on  = 0 ;
    my $slide_name  = "" ;
    my $slide_begin = "" ;  
    my $slide_end   = "" ;
    my $slide_step  = "" ;
    my $slide_index  = "" ;
    
    my $x = "" ;

    #DEBUG
    my $arg = "" ;
    $arg  = join (" || " , @_) ;  
    Filepp::Debug("MNH Debug ::Set_slide_default arg=[[$arg]]\n" ) ;
    
    # Reset Global Default Slide
    @MNH_slide_default_on    = () ;
    @MNH_slide_default_name  = () ;
    @MNH_slide_default_begin = () ;  
    @MNH_slide_default_end   = () ;
    @MNH_slide_default_step  = () ;
    @MNH_slide_default_index  = () ;
    
    # index in the array of slide gatherd
    my $index = -1 ;

    # loop over slide
    foreach $slide (@_) 
    { 
	$index ++ ;
	# surpress space
	$slide =~ s/\s//g ;
	#
	if ( $slide =~ /:/ ) {
	    # slide contain ':' -> Ok ,register it
	    $slide_on  = 1 ;
	    ( $slide_name , $slide_begin, $slide_end , $x ,$slide_step )
		= ( $slide =~ /^\s*([A-z]\w*)=([^:]*):([^:]*)(:([^:]+))?/ ) ;
	    
	    # if not step -> set to 1   
	    $slide_step = "1" if ( !defined($slide_step) ) ;
	    
	    # DEBUG
	    $liste .=  " N=$slide_name = B=$slide_begin :: E=$slide_end :: S=$slide_step "  . " | " ;	 
	}
	else {
	    # slide without ':' <-> index variable or constant , inactivate it 
	    $slide_on  = 0 ;
	    ( $slide_name , $slide_begin, $slide_end ,$slide_step ) = ( "NA" , $slide , "NA", "NA" ) ;
	    $liste .= " $slide |" ;
	}
	
	push ( @MNH_slide_default_on    , $slide_on ) ;
	push ( @MNH_slide_default_name  , $slide_name ) ;
	push ( @MNH_slide_default_begin , $slide_begin ) ;  
	push ( @MNH_slide_default_end   , $slide_end ) ;
	push ( @MNH_slide_default_step  , $slide_step ) ;
	push ( @MNH_slide_default_index ,  0 ) ;
	
    }
    
    Filepp::Debug "MNH Debug::Set_slide_default:on   = @MNH_slide_default_on   \n" ;
    Filepp::Debug "MNH Debug::Set_slide_default:name = @MNH_slide_default_name \n" ;
       
    Filepp::Debug("MNH Debug::Set_slide_default::[$arg] >> $liste" );

    # Output DO nest or DO CONCCURENT
    my $do_list = "" ;
    if(Filepp::Ifdef("MNH_EXPAND_LOOP")) {
	my $indice = "" ;
	my $indent = 0 ;
	foreach $slide (@MNH_slide_default_begin)
	{
	    $slide_on = $MNH_slide_default_on[$index] ;
	    if ( $slide_on ) {
		$slide_name  = $MNH_slide_default_name[$index] ;
		$slide_begin = $MNH_slide_default_begin[$index] ;
		$slide_end   = $MNH_slide_default_end[$index] ;
		$slide_step  = $MNH_slide_default_step[$index] ;
		$indice = "$slide_name=$slide_begin,$slide_end" ;
		$indice .= ",$slide_step" if ( $slide_step ne "1" ) ;
		#add space before do for identation
		for ( my $i=0;$i<$indent;$i++ ) { $do_list .= " " } ; 
		$do_list .= "DO $indice " ;
		$do_list .= "\n" if ( $index != 0 ) ;
		$indent++ ;		
	    }
	    $index-- ; 
	}
	#print "\n" ;
       }
       else {
	   $arg  = join ("," , @_) ;
	   $do_list = "DO CONCURRENT ($arg)" ;
       }
       return $do_list ;    
}
Function::AddFunction("set_slide_default", "MNH::Set_slide_default");

########################################################################
# Get_slide_default all input, usage: - ANY NUMBER OF INPUTS
# Get_slide_default(ii=nib:nie:ip ,ij=njb:nje,jp, ik=nkb:nke,kp ....)
# if dim doesn't contain ':' , slide is not activate
# return ENDDO for loop/do concurrent
########################################################################
sub Get_slide_default
{
    my $arg = join (",",@_) ;
    # Output ENDDO for LOOP or DO CONCURRENT
    my $enddo_list = "" ;
    if(Filepp::Ifdef("MNH_EXPAND_LOOP")) {
	my $index = -1 ;
	my $size = @MNH_slide_default_begin ;
	my $slide ;
	my $slide_on ;
	my $indent = $size-1 ;
	foreach $slide (@MNH_slide_default_begin)
	{
	    $index++ ;
	    $slide_on = $MNH_slide_default_on[$index] ;
	    if ( $slide_on ) {
		#add space before do for identation
		for ( my $i=0;$i<$indent;$i++ ) { $enddo_list .= " " } ;
		$enddo_list .= "ENDDO" ;
		$enddo_list .= "\n" if ( $index < $size-1 ) ;
		$indent-- ;
	    }
	}
	#$enddo_list .= "! [$arg]" ;	
    }
    else {
	$enddo_list = "ENDDO" ; # ! CONCURRENT [$arg]" ;
    }
    return $enddo_list ; 
}
Function::AddFunction("get_slide_default", "MNH::Get_slide_default");    
########################################################################
# Set_slide_left all input, usage: - ANY NUMBER OF INPUTS
# Set_slide_left( A(ii=nib:nie:ip ,ij=njb:nje,jp, ik=nkb:nke,kp ....) )
# if dim doesn't contain ':' , slide is not activate
# if dim contain only ":" -> get value from default
########################################################################
sub Set_slide_left
{
    my $array = '' ;
    my $indice = '' ;
    my @indice_list = () ;
    
    my $liste = '';
    my $slide;

    my $slide_on  = 0 ;
    my $slide_begin = "" ;  
    my $slide_end   = "" ;
    my $slide_step  = "" ;
    my $slide_index  = "" ;
    
    my $x = "" ; 

    #DEBUG
    my $arg = "" ;
    $arg  = join (" || " , @_) ;  
    Filepp::Debug("MNH Debug ::Set_slide_left arg=[[$arg]]\n" ) ;

    # Reset Global Left Slide
    @MNH_slide_left_on    = () ;
    @MNH_slide_left_index  = () ;
    @MNH_slide_left_begin = () ;  
    @MNH_slide_left_end   = () ;
    @MNH_slide_left_step  = () ;

    # Get the array name & indice liste
    ( $array , $indice ) = ( $_[0] =~ /^\s*([A-z]\w*)\((.*)\)/ ) ;
    
    $MNH_slide_left_array  = $array ;
    @indice_list = split ( "," ,  $indice ) ;

    # index in the array of slide gatherd
    my $index = -1 ;
    
    foreach $slide (@indice_list) 
         { 
	     $index ++ ;
	     # surpress space
	     $slide =~ s/\s//g ;
	     if ( $slide =~ /:/ ) {

		 $slide_on  = 1 ;
		 ( $slide_begin, $slide_end , $x ,$slide_step )
		     = ( $slide =~ /([^:]*):([^:]*)(:([^:]+))?/ ) ;

                 # no begin -> get default 
		 $slide_begin = $MNH_slide_default_begin[$index] if ( ! $slide_begin ) ;

                 # no end -> get default 
		 $slide_end = $MNH_slide_default_end[$index] if ( ! $slide_end ) ;
		 
		 # if no step -> set to 1   
		 $slide_step = "1" if ( !defined($slide_step) ) ;		 

		 # DEBUG
		 $liste .=  " B=$slide_begin :: E=$slide_end :: S=$slide_step "  . " | " ;	 
	     }
	     else {
		 $slide_on  = 0 ;
		 ( $slide_begin, $slide_end ,$slide_step ) = ( $slide , "NA", "NA" ) ;
		 $liste .= " $slide |" ;
	     }
	     
	     push ( @MNH_slide_left_on    , $slide_on ) ;
	     push ( @MNH_slide_left_begin , $slide_begin ) ;  
	     push ( @MNH_slide_left_end   , $slide_end ) ;
	     push ( @MNH_slide_left_step  , $slide_step ) ;
	     push ( @MNH_slide_left_index ,  0 ) ;
	     	     
	 }
    Filepp::Debug("MNH Debug ::Set_slide_left:on   = @MNH_slide_left_on   \n") ;
    Filepp::Debug("MNH Debug ::Set_slide_left:array name =$MNH_slide_left_array \n") ;

    Filepp::Debug("MNH Debug ::Set_slide_left:[$arg] >> array{$array} :: $liste\n" ) ;
    
    $index = -1 ;
    foreach $slide (@MNH_slide_left_begin)
    {
	$index ++ ;
	$slide_on =  $MNH_slide_left_on[$index] ;
	if ( $slide_on ) {
	    # remove left/default bound if itentical 
	    if ( $MNH_slide_left_begin[$index] eq $MNH_slide_default_begin[$index]  ) {
		$MNH_slide_left_index[$index] = $MNH_slide_default_name[$index] ;
	    }
	    else {
		$MNH_slide_left_index[$index] = "$MNH_slide_default_name[$index]+$MNH_slide_left_begin[$index]-($MNH_slide_default_begin[$index]) " ;
	    }
	}
	else {
	    # if contante index -> no loop iter index 
	    $MNH_slide_left_index[$index] = $MNH_slide_left_begin[$index] ;
	}
    }
    $indice =  join ("," , @MNH_slide_left_index) ;
    return "$array($indice)";
}
Function::AddFunction("set_slide_left", "MNH::Set_slide_left");

########################################################################
# Set_slide_right all input, usage: - ANY NUMBER OF INPUTS
# Set_slide_right( A(ii=nib:nie:ip ,ij=njb:nje,jp, ik=nkb:nke,kp ....) )
# if dim doesn't contain ':' , slide is not activate
# if dim contain only ":" -> get value from default
########################################################################
sub Set_slide_right
{
    my $array = '' ;
    my $indice = '' ;
    my @indice_list = () ;
    
    my $liste = '';
    my $slide;

    my $slide_on  = 0 ;
    my $slide_begin = "" ;  
    my $slide_end   = "" ;
    my $slide_step  = "" ;
    my $slide_index  = "" ;
    
    my $x = "" ; 

    #DEBUG
    my $arg = "" ;
    $arg  = join (" || " , @_) ;  
    Filepp::Debug("MNH Debug ::Set_slide_right arg=[[$arg]]\n" ) ;
    
    # Reset Global Right Slide
    @MNH_slide_right_on    = () ;
    @MNH_slide_right_index  = () ;
    @MNH_slide_right_begin = () ;  
    @MNH_slide_right_end   = () ;
    @MNH_slide_right_step  = () ;

    # Get the array name & indice liste
    ( $array , $indice ) = ( $_[0] =~ /^\s*([A-z]\w*)\((.*)\)/ ) ;
    
    $MNH_slide_right_array  = $array ;
    @indice_list = split ( "," ,  $indice ) ;

    # index in the array of slide gatherd
    my $index = -1 ;
    
    foreach $slide (@indice_list) 
         { 
	     $index ++ ;
	     # surpress space
	     $slide =~ s/\s//g ;
	     if ( $slide =~ /:/ ) {
		 $slide_on  = 1 ;
		 ( $slide_begin, $slide_end , $x ,$slide_step )
		     = ( $slide =~ /([^:]*):([^:]*)(:([^:]+))?/ ) ;
                 # no begin -> get default 
		 $slide_begin = $MNH_slide_default_begin[$index] if ( ! $slide_begin ) ;
		 # compute delta with left begin	 
		 #if ( $slide_begin eq $MNH_slide_left_begin[$index] ) {
		 #    $slide_begin .= "-($MNH_slide_left_begin[$index])->0" ;
		 #}
		 #else {
		 #    $slide_begin .= "-($MNH_slide_left_begin[$index])" ;
		 #}

                 # no end -> get default 
		 $slide_end = $MNH_slide_default_end[$index] if ( ! $slide_end ) ;
		 # compute delta with left end
		 # if ( $slide_end eq $MNH_slide_left_end[$index] ) {
		 #    $slide_end .= "-($MNH_slide_left_end[$index])->0" ;
		 #}
		 #else {
		 #    $slide_end .= "-($MNH_slide_left_end[$index])" ;
		 #}
		 
		 # if no step -> set to 1   
		 $slide_step = "1" if ( !defined($slide_step) ) ;		 

		 # DEBUG
		 $liste .=  " B=$slide_begin :: E=$slide_end :: S=$slide_step "  . " | " ;	 
	     }
	     else {

		 $slide_on  = 0 ;
		 ( $slide_begin, $slide_end ,$slide_step ) = ( $slide , "NA", "NA" ) ;
		 $liste .= " $slide |" ;
	     }
	     
	     push ( @MNH_slide_right_on    , $slide_on ) ;
	     push ( @MNH_slide_right_begin , $slide_begin ) ;  
	     push ( @MNH_slide_right_end   , $slide_end ) ;
	     push ( @MNH_slide_right_step  , $slide_step ) ;
	     push ( @MNH_slide_right_index ,  0 ) ;	     
	     
	 }

    Filepp::Debug("MNH Debug ::Set_slide_right:on   = @MNH_slide_right_on   \n") ;
    Filepp::Debug("MNH Debug ::Set_slide_right:array name =$MNH_slide_right_array \n") ;
    
    Filepp::Debug("MNH Debug ::Set_slide_right[$arg] >> array{$array} :: $liste\n" ) ;
    
    $index = -1 ;
    foreach $slide (@MNH_slide_right_begin)
    {
	$index ++ ;
	$slide_on = $MNH_slide_right_on[$index] ;
	if ( $slide_on ) {
	    # remove left/default bound if itentical 
	    if ( $MNH_slide_right_begin[$index] eq $MNH_slide_left_begin[$index]  ) {
		$MNH_slide_right_index[$index] = $MNH_slide_default_name[$index] ;
	    }
	    else {
		$MNH_slide_right_index[$index] = "$MNH_slide_default_name[$index]+$MNH_slide_right_begin[$index]-($MNH_slide_left_begin[$index]) " ;
	    }
	}
	else {
	    # if contante index -> no loop iter index
	    $MNH_slide_right_index[$index] = $MNH_slide_right_begin[$index] ;
	}
    }
    $indice =  join ("," , @MNH_slide_right_index) ;
    return "$array($indice)" ;  
}
Function::AddFunction("set_slide_right", "MNH::Set_slide_right");

return 1;
########################################################################
# End of file
########################################################################

