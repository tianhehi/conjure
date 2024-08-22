(local {: describe : it : before-each } (require :plenary.busted))
(local assert (require :luassert.assert))
(local client (require :conjure.client))

(describe "multiple-states? before a change"
  (fn []
    (it "returns false before the first change"
      (fn []
        (assert.is_false (client.multiple-states?))))))

(describe "state-key"
  (fn []
    (it "can be executed to get the current state key"
      (fn []
        (assert.equal :default (client.state-key))))))

(describe "set-state-key!"
  (fn []
    (it "changes the state key value"
      (fn []
        (client.set-state-key! :new-key)
        (assert.equal :new-key (client.state-key))))))

(describe "multiple-states? after a change"
  (fn []
    (it "returns true after the first change"
      (fn []
        (assert.is_true (client.multiple-states?))))))

(describe "new-state"
  (fn []
    (describe "returns a function we can use to look up the current state-key's data for this specific state, the function encloses it's own table of state indexed by state-key"
      (fn []
        (let [state (client.new-state #(do {:foo {:bar 1}}))]
          ;; A "state" is a function
          (assert.is_function state)

          ;; It has a default value from our init-fn under the "default" state
          (assert.equal 1 (state :foo :bar))

          ;; We can swap to a new-state and see the same value
          (client.set-state-key! :new-key)
          (assert.equal 1 (state :foo :bar))

          ;; Changing a value only affects new-state...
          (tset (state :foo) :bar 2)
          (assert.equal 2 (state :foo :bar))

          ;; ...and not the default state
          (client.set-state-key! :default)
          (assert.equal 1 (state :foo :bar)))))))