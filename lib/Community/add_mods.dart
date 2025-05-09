import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadafi_application/Community/common/loader.dart';
import 'package:hadafi_application/Community/controller/community_controller.dart';
import 'package:hadafi_application/Community/provider.dart';

class AddMods extends ConsumerStatefulWidget {
  final String name;
  const AddMods({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsState();
}

class _AddModsState extends ConsumerState<AddMods> {
  Set<String> uids = {};
  Set<String> originalMods = {};
  bool initialized = false; 

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  bool get hasChanges => uids.length != originalMods.length || !uids.containsAll(originalMods);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        centerTitle: true,
        title: const Text(
          'Manage Moderators',
          style: TextStyle(
            // fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select members to assign or remove as moderators",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          Expanded(
            child: ref.watch(getCommunityByNameProvider(widget.name)).when(
                  data: (community) {
                    if (!initialized) {
                      uids.addAll(community.mods);
                      originalMods.addAll(community.mods);
                      initialized = true;
                    }

                    return ListView.builder(
                      itemCount: community.members.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (BuildContext context, int index) {
                        final member = community.members[index];
                        return ref.watch(userDataProvider(member)).when(
                              data: (userData) {
                                if (userData == null || !userData.containsKey('name')) {
                                  return const SizedBox();
                                }
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      children: [
                                        
                                        CircleAvatar(
                                          backgroundColor: Colors.blueGrey.shade100,
                                          child: Text(
                                            userData['name'][0].toUpperCase(),
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 12), 
                                        
                                        
                                        Expanded(
                                          child: CheckboxListTile(
                                            value: uids.contains(member),
                                            onChanged: (val) {
                                              setState(() {
                                                if (val == true) {
                                                  addUid(member);
                                                } else {
                                                  removeUid(member);
                                                }
                                              });
                                            },
                                            title: Text(
                                              userData['name'] as String,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                            ),
                                            controlAffinity: ListTileControlAffinity.trailing, 
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              error: (error, stackTrace) => Center(
                                child: Text(
                                  "Error: $error",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              loading: () => const Loader(),
                            );
                      },
                    );
                  },
                  error: (error, stackTrace) => Center(
                    child: Text(
                      "Error: $error",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  loading: () => const Loader(),
                ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasChanges ? saveMods : null, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasChanges ? const Color(0xFF113F67) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
