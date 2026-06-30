import os
import sys

path = 'mobile/ios/Runner.xcodeproj/project.pbxproj'
if not os.path.exists(path):
    # Fallback if run from the mobile folder
    path = 'ios/Runner.xcodeproj/project.pbxproj'

team_id = os.environ.get('TEAM_ID')
if not team_id:
    print("Error: TEAM_ID environment variable is not set.", file=sys.stderr)
    sys.exit(1)

print(f"Configuring Xcode manual signing for Team ID: {team_id}...")

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace CODE_SIGN_IDENTITY at project level if present
content = content.replace('"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";', '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";')

# 2. Inject signing settings for the Runner build configuration settings
bundle_id_line = 'PRODUCT_BUNDLE_IDENTIFIER = com.alcesbarbearia.app;'
manual_signing_settings = f'''PRODUCT_BUNDLE_IDENTIFIER = com.alcesbarbearia.app;
\t\t\t\tCODE_SIGN_STYLE = Manual;
\t\t\t\tDEVELOPMENT_TEAM = "{team_id}";
\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = "Alces Barbearia AppStore Profile";
\t\t\t\tCODE_SIGN_IDENTITY = "Apple Distribution";'''

content = content.replace(bundle_id_line, manual_signing_settings)

# 3. Inject manual provisioning style under TargetAttributes for the Runner target (97C146ED1CF9000F007C117D)
lines = content.splitlines()
found_target = False
for i, line in enumerate(lines):
    if '97C146ED1CF9000F007C117D = {' in line:
        # Check if DevelopmentTeam is already present to avoid duplicates
        has_dev_team = False
        for j in range(i, min(i + 10, len(lines))):
            if 'DevelopmentTeam' in lines[j]:
                has_dev_team = True
                break
        if not has_dev_team:
            lines.insert(i + 1, f'\t\t\t\t\t\tDevelopmentTeam = "{team_id}";')
            lines.insert(i + 2, '\t\t\t\t\t\tProvisioningStyle = Manual;')
            found_target = True
        break

content = '\n'.join(lines)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Xcode project updated to Manual Signing successfully.")
if not found_target:
    print("Warning: Target attributes for Runner target (97C146ED1CF9000F007C117D) were already updated or not found.")
