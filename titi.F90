 Column=__COLUMN__

@D( ii1=iib:iie:ip , ij=i2jb:ije , k )

@D( 1,j,ik=kb:ke:ks )

@D( ii1=iib+1:iie-1 )


@D( ii1=iib:iie:ip , ij=i2jb:ije , ik=ikb:ike:iks )



A(iib:iie:is , ijb:ije:js , k)

B(:,:,:)

C(iib+1:,ijb-1:,:) = D(iib-1:,ijb-1:,:)

Fct(D(iib-1:,ijb-1:,:))
 
 !$mnh_expand_array(ii1=iib:iie:ip , ij=i2jb:ije , ik=ikb:ike:iks) 

    F (iib:iie:ip,i2jb:ije,:) =  D ( iib:iie:ip , i2jb:ije , : ) + Fct(D(iib-1:,ijb-1:,:))
    C( iib: iie :ip , i2jb: ije , k)

    D( i: , j,k )

 !$mnh_end_expand_array(ii1=iib:iie:ip,ij=i2jb:ije,ik=ikb:ike:iks)

Fct(D(iib-1:,ijb-1:,:))

  !$mnh_do_concurrent(ii1=iib:iie:ip , ij=i2jb:ije , ik=ikb:ike:iks)

     A(ii1,ij,ik) = B(ii1-1,ij,ik )

  !$mnh_end_do()
