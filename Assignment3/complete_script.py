import pandas as pd
import itertools

df = pd.read_csv("./myDataFile.csv", low_memory=False)
df.fillna(0, inplace=True)
df.replace('t', 1, inplace=True)


def compute_support_for(df, item_set):
    # df is the (reference to) complete dataframe
    # item_set is a set of strings, each being a column name in df to be checked.
    # returns the support percentage for a given item_set.

    if len(item_set) == 0:
        return 0

    query = " == 1 and ".join(item_set) + " == 1"
    return df.query(query).shape[0] / df.shape[0]


def pick_candidates_for_layer(candidates, df, minSup):
    return [item_set for item_set in candidates if compute_support_for(df, item_set) >= minSup]


def compute_frequent_item_sets(df, min_support):
    # Define first layer candidates in a dictionary
    candidates = {
        1: [{item} for item in list(df.columns)]
    }

    # Compute first layer frequent item sets.
    layers = {
        1: pick_candidates_for_layer(candidates[1], df, min_support)
    }

    n_columns = df.shape[1]
    for layer in range(2, n_columns + 1):

        # Step 1 - Self-join. Compute candidates for current layer
        candidates[layer] = list()
        for p in range(len(layers[layer - 1]) - 1):

            for q in range(p + 1, len(layers[layer - 1])):  # start at p+1 to avoid duplicates.

                p_set = layers[layer - 1][p]
                q_set = layers[layer - 1][q]

                # Check if the number of common elements between the two item sets equals layer - 2.
                # If so, they differ by one element and a new candidate (union) can be computed.
                if len(p_set.intersection(q_set)) == layer - 2:
                    new_candidate = p_set.union(q_set)

                    # Only append if not a duplicate
                    if not new_candidate in candidates[layer]:

                        # Step 2 - Pruning (based on existence of subsets in previous layer)
                        subsets_of_new_candidate = set(itertools.combinations(new_candidate, layer - 1))
                        if all([set(subset) in layers[layer - 1] for subset in subsets_of_new_candidate]):
                            candidates[layer].append(new_candidate)

        # Pick item sets for layer if they exceed the minimum support.
        picked = pick_candidates_for_layer(candidates[layer], df, min_support)

        # Break early if no more frequent item sets are found.
        if len(picked) == 0:
            break

        layers[layer] = picked

        print("Finished computing for layer " + str(layer))

    return layers, candidates


# takes 3 input parameters, the reference to the dataframe and 2 item sets
def compute_confidence(df, antecedent, consequent):
    return compute_support_for(df, set.union(antecedent, consequent)) / compute_support_for(df, antecedent)


def compute_rules_for(df, antecedents, consequents, min_conf, rules):
    # Base case, no more consequents for valid rule.
    if len(antecedents) == 0:
        return rules

    # For each consequent
    for antecedent in antecedents:

        next_consequents = consequents.copy()
        next_consequents.add(antecedent)  # add single antecedent to consequent set.

        # Create copy (because python) of antecedents and remove one antecedent.
        next_antecedents = antecedents.copy()
        next_antecedents.remove(antecedent)

        # Skip duplicates
        if frozenset(next_antecedents) in rules and frozenset(next_consequents) in rules[frozenset(next_antecedents)]:
            continue

        # Compute confidence for possible new rule.
        conf = compute_confidence(df, next_antecedents, next_consequents)

        # If rule passes min confidence, add to rules
        if conf >= min_conf:

            # Add to the dict
            if frozenset(next_antecedents) in rules:
                rules[frozenset(next_antecedents)][frozenset(next_consequents)] = conf
            else:
                rules[frozenset(next_antecedents)] = {
                    frozenset(next_consequents): conf
                }

            if len(next_antecedents) > 1:
                # Only then, go into recursion on these item sets.
                compute_rules_for(df, next_antecedents, next_consequents, min_conf, rules)


def generate_all_rules(df, layers, min_conf, rules):
    # For each layer of the item sets
    for k, item_sets in layers.items():

        # No rules can be formed out of item sets with length 1.
        if k == 1:
            continue

        # Per item set in this layer...
        for item_set in item_sets:
            # ... compute the rules
            compute_rules_for(df, item_set, set([]), min_conf, rules)

        print("Computed rules for item sets of length " + str(k) + ":")


# Method to prettify frozenset strings.
def pretty(item_set):
    return "{" + ", ".join(item_set) + "}"


if __name__ == '__main__':

    # First, compute item sets
    L, C = compute_frequent_item_sets(df, 0.005)

    rules = {}

    # Then generate the rules
    generate_all_rules(df, L, 0.6, rules)

    # Show results for computing the item sets
    print("Lengths for L:")
    for key, value in L.items():
        print(str(key) + ": " + str(len(value)))

    # Show results for the rules
    count = 0
    for antecedent in rules.keys():
        # print("Ant: " + str(antecedent) + ", con: " + str(rules[antecedent]))
        count += len(rules[antecedent].keys())

        for consequent in rules[antecedent].keys():
            print(pretty(antecedent) + " -> " + pretty(consequent) + " (confidence = " + str(
                rules[antecedent][consequent]) + ")")

    print("Rule count: " + str(count))
