-- Sage's Cloak of Phantom
local s, id = GetID()

function s.initial_effect(c)
    -- Special Summon if a card on the field is banished
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_REMOVE)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Destroy 1 Spell/Trap card when a DARK Spellcaster monster declares an attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- Other DARK Spellcaster monsters you control cannot be targeted by opponent's card effects
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE, 0)
    e3:SetTarget(s.tgtg)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_DARK_MAGICIAN), tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil)
        and eg:IsExists(Card.IsLocation, 1, nil, LOCATION_ONFIELD)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_DARK_MAGICIAN), tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil)
        and Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsAttribute(ATTRIBUTE_DARK)
        and Duel.GetAttacker():IsType(TYPE_SPELLCASTER)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDestructable, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, Card.IsDestructable, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
end

function s.tgtg(e, c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SPELLCASTER) and c ~= e:GetHandler()
end