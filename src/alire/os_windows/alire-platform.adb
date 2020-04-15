with Alire.Utils;
with Alire.OS_Lib;            use Alire.OS_Lib;
with Alire.OS_Lib.Subprocess;
with Alire.Origins;
with Alire.Origins.Deployers;

package body Alire.Platform is

   --  Windows implementation

   Distrib_Detected : Boolean := False;
   Distrib : Platforms.Distributions := Platforms.Distro_Unknown;

   ------------------
   -- Detect_Msys2 --
   ------------------

   function Detect_Msys2 return Boolean is
      use Alire.Utils;
   begin
      --  Try to detect if Msys2's pacman tool is already in path
      declare
         Unused : Utils.String_Vector;
      begin
         OS_Lib.Subprocess.Checked_Spawn_And_Capture
           ("pacman", Utils.Empty_Vector & ("-V"),
            Unused,
            Err_To_Out => True);
         return True;
      exception when others =>
            null;
      end;

      return False;
   end Detect_Msys2;

   ---------------------------
   -- Default_Config_Folder --
   ---------------------------

   function Default_Config_Folder return String is
   begin
      return Getenv ("HOMEDRIVE") & Getenv ("HOMEPATH") / ".config" / "alire";
   end Default_Config_Folder;

   --------------------
   -- Detect_Distrib --
   --------------------

   procedure Detect_Distrib is
   begin
      Distrib_Detected := True;

      if Detect_Msys2 then
         Distrib := Platforms.Msys2;
         return;
      end if;

      Distrib := Platforms.Distro_Unknown;
   end Detect_Distrib;

   ------------------
   -- Distribution --
   ------------------

   function Distribution return Platforms.Distributions is
   begin
      if not Distrib_Detected then
         Detect_Distrib;
      end if;

      return Distrib;
   end Distribution;

end Alire.Platform;
