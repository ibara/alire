with AAA.Enum_Tools;

with Alire.Crates;
with Alire.Externals.From_Output;
with Alire.Externals.Unindexed;
with Alire.TOML_Keys;
with Alire.TOML_Load;

with TOML;

package body Alire.Externals is

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (From : TOML_Adapters.Key_Queue) return External'Class is

      ---------------
      -- From_TOML --
      ---------------

      function From_TOML (Kind : Kinds) return External'Class is
        (case Kind is
            when Hint           => Unindexed.External'
                                     (External with null record),
            when Version_Output => From_Output.From_TOML (From));

      Kind : TOML.TOML_Value;
      OK   : constant Boolean := From.Pop (TOML_Keys.External_Kind, Kind);

      --------------
      -- Validate --
      --------------

      procedure Validate is
         function Is_Valid is new AAA.Enum_Tools.Is_Valid (Kinds);
      begin
         if not OK then
            From.Checked_Error ("missing external kind field");
         end if;

         if Kind.Kind not in TOML.TOML_String then
            From.Checked_Error ("external kind must be a string, but got a "
                                & Kind.Kind'Img);
         elsif not Is_Valid (TOML_Adapters.Adafy (Kind.As_String)) then
            From.Checked_Error ("external kind is invalid: " & Kind.As_String);
         end if;
      end Validate;

      Deps : Conditional.Dependencies;

   begin

      --  Check TOML types

      Validate;

      --  Load specific external part

      return Ext : External'Class :=
        From_TOML (Kinds'Value (TOML_Adapters.Adafy (Kind.As_String)))
      do

         --  Load common external fields

         declare
            Result : constant Outcome :=
                     TOML_Load.Load_Crate_Section
                       (Section => Crates.External_Section,
                        From    => From,
                        Props   => Ext.Properties,
                        Deps    => Deps,
                        Avail   => Ext.Available);
         begin
            Assert (Result);

            --  Ensure that no dependencies have been defined for the external.
            --  This may be handy in the future, but until the need arises
            --  better not have it complicating things.
         end;

         if not Deps.Is_Empty then
            From.Checked_Error ("externals cannot have dependencies");
         end if;

         From.Report_Extra_Keys; -- Table must be exhausted at this point
      end return;

   exception
      when Checked_Error =>
         raise;
      when E : others =>
         Log_Exception (E);
         From.Checked_Error
           ("invalid external description (see details with -d)");
   end From_TOML;

end Alire.Externals;
