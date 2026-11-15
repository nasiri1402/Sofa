// Source/configuration contract checks, not a substitute for StoreKit runtime QA.
// Run from any directory with Node.js 18+: node scripts/verify-monthly-paywall.mjs
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
const root = new URL('../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
const parse = path => JSON.parse(read(path));
const model = read('Sofa/Presentations/Paywall/PaywallModel.swift');
const vm = read('Sofa/Presentations/Paywall/PaywallViewModel.swift');
const view = read('Sofa/Presentations/Paywall/PaywallView.swift');
const store = read('Sofa/Services/StoreManager/StoreManager.swift');
const gift = read('Sofa/Presentations/GiftPaywall/GiftPaywallModel.swift');
const giftVM = read('Sofa/Presentations/GiftPaywall/GiftPaywallViewModel.swift');
const giftView = read('Sofa/Presentations/GiftPaywall/GiftPaywallView.swift');
const catalog = parse('Sofa/Sources/Localizable/Localizable.xcstrings');
const terms = parse('Sofa/Sources/Localizable/SubscriptionTerms.xcstrings');
const products = parse('Sofa/Sources/SupportingFiles/Sofa.storekit')
  .subscriptionGroups.flatMap(group => group.subscriptions);
let checks = 0;
const check = (label, fn) => { fn(); checks++; console.log(`PASS ${label}`); };

check('New purchase choices are annual and monthly, not weekly', () => {
  assert.match(model, /case yearly, monthly/);
  assert.match(model, /com\.ai\.sofa\.subscriptions\.month"/);
  assert.doesNotMatch(model, /case .*weekly|subscriptions\.week/);
});
check('Annual product and Gift product identity remain unchanged', () => {
  assert.match(model, /com\.ai\.sofa\.subscriptions\.year"/);
  assert.match(gift, /PaywallModel\.Subscription\.yearly\.id \+ "\.gift"/);
});
check('Annual is selected by default, with stable catalog ordering', () => {
  assert.match(vm, /self\.selectedSubscription = \.yearly/);
  assert.match(vm, /Subscription\.allCases\.filter/);
  assert.match(vm, /!subscriptions\.contains\(selectedSubscription\)/);
});
check('Three-day free trial requires an actual offer AND eligibility', () => {
  for (const fragment of [
    'info.introductoryOffer', 'offer.paymentMode == .freeTrial',
    'offer.period.unit == .day', 'offer.period.value == 3',
    'offer.periodCount == 1', 'await info.isEligibleForIntroOffer',
    'canStartMonthlyTrial = false',
  ]) assert.ok(vm.includes(fragment), fragment);
  assert.doesNotMatch(model, /var withTrial/);
  assert.match(view, /title: viewModel\.isTrialOn/);
});
check('No silent paid purchase if trial eligibility changes', () => {
  assert.match(vm, /guard !wasTrialPromised \|\| canStartMonthlyTrial else \{ return \}/);
});
check('No trial toggle can silently switch the billing period', () => {
  assert.doesNotMatch(view, /TrialView\(|Toggle\(/);
  const trialProperty = vm.slice(vm.indexOf('var isTrialOn:'), vm.indexOf('var canPurchase:'));
  assert.doesNotMatch(trialProperty, /\bset\s*\{/);
});
check('Gift discount has no fallback percentage or invented comparison', () => {
  assert.doesNotMatch(giftVM, /defaultDiscount/);
  assert.match(giftVM, /func formatDiscountBadge\(\) -> String\?/);
  assert.match(giftVM, /giftProduct\.price < standardProduct\.price/);
  assert.match(giftVM, /standardProduct\.priceFormatStyle\.currencyCode == giftProduct\.priceFormatStyle\.currencyCode/);
  assert.match(giftVM, /standardPeriod\.value == giftPeriod\.value/);
  assert.match(giftView, /if let badge = viewModel\.formatDiscountBadge\(\)/);
});
check('Main paywall blocks missing products and duplicate purchase taps', () => {
  assert.match(vm, /!isLoading && findProduct\(for: selectedSubscription\) != nil/);
  assert.match(view, /\.disabled\(!viewModel\.canPurchase\)/);
});
check('Annual comparison is per month, full price remains primary', () => {
  assert.match(vm, /case \.year: productPrice \/ 12/);
  assert.match(view, /subscription\.title \+ " - " \+ viewModel\.formatPrice/);
  assert.match(view, /subtitle: viewModel\.isTrialOn .* : price/);
});
check('Legacy weekly entitlements do not depend on new purchase choices', () => {
  const entitlementMethod = store.slice(store.indexOf('func updatePurchasedProducts() async {'),
    store.indexOf('func getProducts() async throws -> [Product] {'));
  assert.match(entitlementMethod, /Transaction\.currentEntitlements/);
  assert.match(entitlementMethod, /purchasedProductIDs\.insert\(transaction\.productID\)/);
  assert.doesNotMatch(entitlementMethod, /Subscription|allCases|products\.contains/);
});
check('StoreKit fixtures include monthly trial, legacy week, annual and Gift', () => {
  const get = id => products.find(p => p.productID === `com.ai.sofa.subscriptions.${id}`);
  assert.equal(get('month').displayPrice, '4.99');
  assert.equal(get('month').recurringSubscriptionPeriod, 'P1M');
  assert.equal(get('month').introductoryOffer.subscriptionPeriod, 'P3D');
  assert.equal(get('month').introductoryOffer.paymentMode, 'free');
  assert.equal(get('year').displayPrice, '39.99');
  assert.equal(get('year.gift').displayPrice, '29.99');
  assert.deepEqual(get('year.gift').introductoryOffers, []);
  assert.equal(get('week.3trial').recurringSubscriptionPeriod, 'P1W');
  assert.equal(get('week.3trial').displayPrice, '5.99');
  assert.equal(new Set(products.map(p => p.productID)).size, products.length);
});
check('All existing paywall locales have renewal disclosures and price labels', () => {
  const locales = Object.keys(catalog.strings.try3DaysFree.localizations);
  assert.deepEqual(Object.keys(terms.strings.renewsAutomatically.localizations).sort(), locales.sort());
  for (const key of ['continue', 'month', 'year', 'monthsPluralFormat', 'yearsPluralFormat']) {
    for (const locale of locales) assert.ok(catalog.strings[key].localizations[locale], `${key}: ${locale}`);
  }
});
console.log(`${checks} source/configuration checks passed in ${fileURLToPath(root)}`);
