// Full tree resources are loaded before exploration. Keep the complete meshes
// across a wider approach region so nearby travel cannot cross the atlas fade.
export const treeDetailPolicy = {
 fullUntilMetres:80,
 transitionEndMetres:110,
 submitUntilMetres:125,
} as const;
