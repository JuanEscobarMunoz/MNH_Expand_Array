#pragma filepp UseModule bigdef.pm
#pragma filepp UseModule bigfunc.pm
!pragma filepp UseModule /home/escj/PATCH/FILEPP/MNH.pm
  

#define @X(i,j) (IIB##i:IIE##i,IJB##j:IJE##j)
  
#define @D( args... )  set_slide_default( args )  
#define @R( args... )  set_slide_right( args )
#define @L( args... )  set_slide_left( args )

#bigfunc expand( args... )
HELLO args
#endbigfunc

expand ( a,b,c )

#bigfunc maxsize(ii,jj)
#define IIU ii
#define IJU jj
#endbigfunc

#bigfunc domaine(ib,ie,jb,je)
#define IIB ib
#define IIE ie
#define IJB jb
#define IJE je
#endbigfunc

A@X(+1,-1)

A@X(,) = B@X(-1,-1) + B@X(+1,+1) &
      + B@X(-1,+1) + B@X(+1,-1)

maxsize(iiu,jju)
domaine(iib,iie,ijb,ije)

set_slide_default( ii=iib:iie:is , ij=ijb:ije:js , k  )

@D( ii1=iib:iie:ip , ij=i2jb:ije , k )

@D( 1,j,ik=1:2:kb:ke:ks )

@D( ii1=iib:iie )

@D( ii1=iib:iie:ip , ij=i2jb:ije , ik=ikb:ike )

@L(A(iib:iie:is , ijb:ije:js , k))

@R(A(iib:iie:is , ijb:ije:js , k))

@L(B(:,:,:)) 



Fct(@R(D(iib-1:,ijb-1:,:)))

