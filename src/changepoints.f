c     Ternary segmentation with permutation reference distribution
      subroutine fndcpt(n,w,wn,wloc,x,px,sx,tx,nperm,cpval,ncpt,icpt,
     1     ibin)
      integer n,w,wn,wloc(wn),nperm,ncpt,icpt(2)
      logical ibin
      double precision x(n),px(n),sx(w),tx(w),cpval

      integer np,nrej,nrejc,iseg(3),n1,n2,n12,l
      double precision ostat,pstat,tpval

      call rndstart()

      nrejc = int(cpval*dfloat(nperm))
      nrej = 0
      nw = max(n-w,0)
      nn = min(n,w)
      call tmax1(n,w,wn,wloc,x,sx,tx,iseg,ostat,ibin)
      ostat = ostat * 0.99999
c      call dblepr("Max Stat",8,ostat,1)
c      call intpr("Location",8,iseg,3)
      ncpt = 0
      do 100 np = 1,nperm
         call xperm(n,x,px)
         pstat = tmax(n,w,wn,wloc,px,sx,tx,ibin)
c         call dblepr("Perm Max Stat",13,pstat,1)
         if (ostat.le.pstat) nrej = nrej + 1
c         call intpr("num rej",7,nrej,1)
         if (nrej.gt.nrejc) go to 500
 100  continue
      if (iseg(2).eq.w) then
         ncpt = 1
         icpt(1) = iseg(1) + iseg(3)
      else
         if(iseg(1).eq.0) then
            ncpt = 1
            icpt(1) = iseg(2) + iseg(3)
         else
            l = iseg(3) + 1
            n1 = iseg(1)
            n12 = iseg(2)
            n2 = n12 - n1
            tpval = tpermp(n1,n2,n12,x(l),px,nperm)
c            call dblepr("binseg p-value",14,tpval,1)
            if (tpval.le.cpval) then
               ncpt = 1
               icpt(1) = iseg(1) + iseg(3)
            endif
            l = iseg(1) + iseg(3) + 1
            n12 = w - iseg(1)
            n2 = w - iseg(2)
            n1 = n12 - n2
            tpval = tpermp(n1,n2,n12,x(l),px,nperm)
c            call dblepr("binseg p-value",14,tpval,1)
            if (tpval.le.cpval) then
               ncpt = ncpt + 1
               icpt(ncpt) = iseg(2) + iseg(3)
            endif
         endif
      endif

 500  call rndend()

      return
      end

      function tmax(n,w,wn,wloc,px,sx,tx,ibin)
      integer n,w,wn,wloc(wn)
      double precision tmax,px(n),sx(w),tx(w)
      logical ibin

      integer i,j,k,l
c      double precision xsum,sx2,x1,x2,rj,rn,tij,xvar,
      double precision sumx,ssqx,xbar,rw,rj,absx,sxmx,bssmx,wtmax,tss

      rw = dfloat(w)
      tmax = 0.0
      do 100 k = 1,wn
         l = wloc(k)
         sumx = 0.0
         ssqx = 0.0
         do 10 i = 1,w
            sumx = sumx + px(l+i)
            ssqx = ssqx + px(l+i)**2
 10      continue
         xbar = sumx/rw
         tss = ssqx - sumx*xbar
         do 20 i = 1,w
            tx(i) = px(l+i) - xbar
            sx(i) = tx(i)
 20      continue
         wtmax = 0.0
         do 40 j = 2,(w-1)/2
            rj = dfloat(j)
            sxmx = 0.0
            do 30 i = 1,w
               sx(i) = sx(i) + tx(1+mod(i+j-2,w))
               absx = abs(sx(i))
               if (sxmx.lt.absx) sxmx = absx
 30         continue
            if (ibin) then
               bssmx = rw*(abs(sxmx)-0.5)**2/(rj*(rw-rj))
            else
               bssmx = rw*sxmx**2/(rj*(rw-rj))
            endif
            if (wtmax.lt.bssmx) wtmax = bssmx
 40      continue
         if (w.eq.2*(w/2)) then
            j = w/2
            rj = dfloat(j)
            sxmx = 0.0
            do 50 i = 1,w/2
               sx(i) = sx(i) + tx(1+mod(i+j-2,w))
               absx = abs(sx(i))
               if (sxmx.lt.absx) sxmx = absx
 50         continue
            if (ibin) then
               bssmx = rw*(abs(sxmx)-0.5)**2/(rj*(rw-rj))
            else
               bssmx = rw*sxmx**2/(rj*(rw-rj))
            endif
            if (wtmax.lt.bssmx) wtmax = bssmx
         endif
         if (ibin) then
            if (tss.le.0.0001) tss = 1.0
            wtmax = wtmax/(tss/rw)
         else
            if (tss.le.wtmax+0.0001) tss = wtmax + 1.0
            wtmax = wtmax/((tss-wtmax)/(rw-2.0))
         endif
         if (tmax.lt.wtmax) tmax = wtmax
 100  continue

      return
      end

      subroutine tmax1(n,w,wn,wloc,x,sx,tx,iseg,ostat,ibin)
      integer n,w,wn,wloc(wn),iseg(3)
      double precision x(n),sx(w),tx(w),ostat
      logical ibin

      integer i,j,k,l, sxmxi, wtmxi, wtmxj
c      double precision xsum,sx2,x1,x2,rij,rw,tij,xvar
      double precision sumx,ssqx,xbar,rw,rj,absx,sxmx,bssmx,wtmax,tss

      rw = dfloat(w)
      ostat = -0.5
      do 100 k = 1,wn
         l = wloc(k)
         sumx = 0.0
         ssqx = 0.0
         do 10 i = 1,w
            sumx = sumx + x(l+i)
            ssqx = ssqx + x(l+i)**2
 10      continue
         xbar = sumx/rw
         tss = ssqx - sumx*xbar
         do 20 i = 1,w
            tx(i) = x(l+i) - xbar
            sx(i) = tx(i)
 20      continue
         wtmax = -0.5
         do 40 j = 2,(w-1)/2
            rj = dfloat(j)
            sxmx = -0.5
            do 30 i = 1,w
               sx(i) = sx(i) + tx(1+mod(i+j-2,w))
               absx = abs(sx(i))
               if (sxmx.lt.absx) then 
                  sxmx = absx
                  sxmxi = i
               endif
 30         continue
            if (ibin) then
               bssmx = rw*(abs(sxmx)-0.5)**2/(rj*(rw-rj))
            else
               bssmx = rw*sxmx**2/(rj*(rw-rj))
            endif
            if (wtmax.lt.bssmx) then 
               wtmax = bssmx
               wtmxi = sxmxi
               wtmxj = j
            endif
 40      continue
         if (w.eq.2*(w/2)) then
            j = w/2
            rj = dfloat(j)
            sxmx = -0.5
            do 50 i = 1,w/2
               sx(i) = sx(i) + tx(1+mod(i+j-2,w))
               absx = abs(sx(i))
               if (sxmx.lt.absx) then 
                  sxmx = absx
                  sxmxi = i
               endif
 50         continue
            if (ibin) then
               bssmx = rw*(abs(sxmx)-0.5)**2/(rj*(rw-rj))
            else
               bssmx = rw*sxmx**2/(rj*(rw-rj))
            endif
            if (wtmax.lt.bssmx) then
               wtmax = bssmx
               wtmxi = sxmxi
               wtmxj = j
            endif
         endif
         if (ibin) then
            if (tss.le.0.0001) tss = 1.0
            wtmax = wtmax/(tss/rw)
         else
            if (tss.le.wtmax+0.0001) tss = wtmax + 1.0
            wtmax = wtmax/((tss-wtmax)/(rw-2.0))
         endif
         if (ostat.lt.wtmax) then
            ostat = wtmax
            if (wtmxi+wtmxj-1.le.w) then
               iseg(1) = wtmxi-1
               iseg(2) = wtmxi-1+wtmxj
            else
               iseg(1) = wtmxi-1+wtmxj-w
               iseg(2) = wtmxi-1
            endif
            iseg(3) = l
         endif
 100  continue

      return
      end

      subroutine xperm(n,x,px)
      integer n
      double precision x(n),px(n)

      integer i,j
      double precision dunif,cc,tmpx

      do 10 i = 1,n
         px(i) = x(i)
 10   continue

      do 20 i = n,1,-1
         cc = dunif()
         j = int(cc*dfloat(i))+1
         tmpx = px(i)
         px(i) = px(j)
         px(j) = tmpx
 20   continue
      return
      end

      function tpermp(n1,n2,n,x,px,nperm)
      integer n1,n2,n,nperm
      double precision x(n),px(n),tpermp
      integer np,i,m1
      double precision xsum1,xsum2,xbar,ostat,pstat,rn1,rn2,rm1

      rn1 = dfloat(n1)
      rn2 = dfloat(n2)
      if (n1.eq.1 .or. n2.eq.1) then
         nrej = nperm
         go to 110
      endif
      xsum1 = 0.0
      do 10 i=1,n1
         xsum1 = xsum1 + x(i)
 10   continue
      xsum2 = 0.0
      do 20 i=n1+1,n
         xsum2 = xsum2 + x(i)
 20   continue
      xbar = (xsum1 + xsum2)/(rn1+rn2)
      if (n1.le.n2) then
         m1 = n1
         rm1 = rn1
         ostat = 0.99999*abs(xsum1/rn1 - xbar)
      else
         m1 = n2
         rm1 = rn2
         ostat = 0.99999*abs(xsum2/rn2 - xbar)
      endif
c      call dblepr("O-Stat",6,ostat,1)
      nrej = 0
      do 100 np = 1,nperm
         call xperm(n,x,px)
         xsum1 = 0.0
         do 30 i=1,m1
            xsum1 = xsum1 + px(i)
 30      continue
         pstat = abs(xsum1/rm1 - xbar)
c         call dblepr("P-Stat",6,pstat,1)
         if (ostat.le.pstat) nrej = nrej + 1
 100  continue
 110  tpermp = dfloat(nrej)/dfloat(nperm)

      return
      end
