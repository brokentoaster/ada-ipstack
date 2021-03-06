------------------------------------------------------------------------------
--                            IPSTACK COMPONENTS                            --
--  Adapted by Manuel Iglesias (Mhanuel.Usb@gmail.com)
--  Copyright (C) 2017.
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-------------------------------------------------------------------------------

--  IP layer

with System;
with Net;

with AIP.IPaddrs, AIP.NIF, AIP.Buffers;
limited with AIP.UDP, AIP.TCP;

package AIP.IP with
  Abstract_State => (FIB, State),
  Initializes    => (FIB, State)
is

   Icmp_Count   : Net.Uint32 := 0;
   Icmp_Tbytes  : Net.Uint64 := 0;

   procedure Set_Default_Router (IPA : IPaddrs.IPaddr)
   --  Set the default route to the given value
   with
     Global => (Output => FIB);

   procedure IP_Route
     (Dst_IP   : IPaddrs.IPaddr;
      Next_Hop : out IPaddrs.IPaddr;
      Netif    : out AIP.EID)
   --  Find next hop IP address and outbound interface for Dst_IP
   with
     Global => (Input  => FIB);

   procedure IP_Input (Netif : NIF.Netif_Id; Buf : Buffers.Buffer_Id) with
     Global => (Input  => UDP.State,
                In_Out => (Buffers.State, TCP.State));

   procedure IP_Output_If
     (Buf    : Buffers.Buffer_Id;
      Src_IP : IPaddrs.IPaddr;
      Dst_IP : IPaddrs.IPaddr;
      NH_IP  : IPaddrs.IPaddr;
      TTL    : AIP.U8_T;
      TOS    : AIP.U8_T;
      Proto  : AIP.U8_T;
      Netif  : NIF.Netif_Id;
      Err    : out AIP.Err_T)
   --  Output IP datagram
   with
     Global => (In_Out => (Buffers.State, State));

   procedure Get_Next_Header
     (Buf  : Buffers.Buffer_Id;
      Nlen : AIP.U16_T;
      Nhdr : out System.Address;
      Err  : out AIP.Err_T)
   --  Given an IP buffer, verify that at least Nlen bytes of data are present
   --  in the payload (accomodating data for the next-level protocol header).
   --  If so, move Buf's payload pointer to the start of the next header, and
   --  return it in Nhdr, else set Err.
   with
     Global => (In_Out => Buffers.State);

private

   procedure IP_Forward (Buf : Buffers.Buffer_Id; Netif : NIF.Netif_Id)
   --  Decrement TTL and forward packet to next hop
   with
     Global => (In_Out => Buffers.State);

end AIP.IP;
